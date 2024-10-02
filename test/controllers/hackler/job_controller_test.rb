# frozen_string_literal: true

require "test_helper"

module Hackler
  class JobControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get enqueue" do
      get job_enqueue_url

      assert_response :success
    end

    test "should get work" do
      get job_work_url

      assert_response :success
    end
  end
end
