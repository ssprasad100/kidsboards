# Update family command
class Family::FamilyUpdateCommand < Core::Command
  attr_accessor :name, :photo_url

  validates :name,      length: { maximum: 50 }
  validates :photo_url, length: { maximum: 100 }
  validates :photo_url, 'Core::Validator::Uri' => true

  # Sets all variables
  # @param [Object] params
  # @see User::AuthorizationService
  # @see Family::FamilyRepository
  def initialize(params)
    super(params)
    @authorization_service = User::AuthorizationService.get
    @family_repository = Family::FamilyRepository.get
  end

  # Runs command
  def execute
    user = @authorization_service.get_user_by_token_code(token)
    family = user.family
    family.name = name unless name.nil?
    family.photo_url = photo_url unless photo_url.nil?
    @family_repository.save!(family)
    nil
  end
end