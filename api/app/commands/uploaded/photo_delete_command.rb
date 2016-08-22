# Photo delete command
class Uploaded::PhotoDeleteCommand < Core::Command
  attr_accessor :id
  attr_accessor :photo_repository

  validates :id, presence: true,
                 'Core::Validator::Exists' => ->(x) { x.photo_repository.find_not_deleted(x.id) }
  validates :id, 'Core::Validator::Owner' => ->(x) { x.photo_repository.find(x.id) }

  # Sets all services
  # @param [Object] params
  # @see Uploaded::PhotoRepository
  def initialize(params)
    super(params)
    @photo_repository = Uploaded::PhotoRepository.get
  end

  # Runs command
  def execute
    photo = @photo_repository.find(id)
    @photo_repository.delete(photo)
    nil
  end
end