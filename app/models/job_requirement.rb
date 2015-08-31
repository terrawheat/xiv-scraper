class JobRequirement < ActiveRecord::Base
  belongs_to :item
  belongs_to :job
end
