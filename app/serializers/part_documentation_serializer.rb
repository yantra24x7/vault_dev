class PartDocumentationSerializer < ActiveModel::Serializer
  attributes :id, :part_number, :program_number, :revision_no, :editor, :part_produced_in_this_setup, :job_number, :part_drawing
  has_one :customer
  has_one :machine
end
