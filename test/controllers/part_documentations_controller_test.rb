require 'test_helper'

class PartDocumentationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @part_documentation = part_documentations(:one)
  end

  test "should get index" do
    get part_documentations_url, as: :json
    assert_response :success
  end

  test "should create part_documentation" do
    assert_difference('PartDocumentation.count') do
      post part_documentations_url, params: { part_documentation: { customer_id: @part_documentation.customer_id, editor: @part_documentation.editor, job_number: @part_documentation.job_number, machine_id: @part_documentation.machine_id, part_drawing: @part_documentation.part_drawing, part_number: @part_documentation.part_number, part_produced_in_this_setup: @part_documentation.part_produced_in_this_setup, program_number: @part_documentation.program_number, revision_no: @part_documentation.revision_no } }, as: :json
    end

    assert_response 201
  end

  test "should show part_documentation" do
    get part_documentation_url(@part_documentation), as: :json
    assert_response :success
  end

  test "should update part_documentation" do
    patch part_documentation_url(@part_documentation), params: { part_documentation: { customer_id: @part_documentation.customer_id, editor: @part_documentation.editor, job_number: @part_documentation.job_number, machine_id: @part_documentation.machine_id, part_drawing: @part_documentation.part_drawing, part_number: @part_documentation.part_number, part_produced_in_this_setup: @part_documentation.part_produced_in_this_setup, program_number: @part_documentation.program_number, revision_no: @part_documentation.revision_no } }, as: :json
    assert_response 200
  end

  test "should destroy part_documentation" do
    assert_difference('PartDocumentation.count', -1) do
      delete part_documentation_url(@part_documentation), as: :json
    end

    assert_response 204
  end
end
