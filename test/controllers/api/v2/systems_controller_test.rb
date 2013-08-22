# encoding: utf-8
#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "minitest_helper"

class Api::V2::SystemsControllerTest < Minitest::Rails::ActionController::TestCase

  fixtures :all

  def self.before_suite
    models = ["System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def models
    @system = systems(:simple_server)
    @system_groups = system_groups
  end

  def permissions
    @read_permission = UserPermission.new(:read, :systems)
    @create_permission = UserPermission.new(:create, :systems)
    @update_permission = UserPermission.new(:update, :systems)
    @no_permission = NO_PERMISSION
  end

  def setup
    login_user(User.find(users(:admin)))
    @request.env['HTTP_ACCEPT'] = 'application/json'
    System.any_instance.stubs(:releaseVer).returns(1)
    models
    permissions
  end

  def test_show
    get :show, :id => @system.uuid

    assert_response :success
    assert_template 'api/v2/systems/show'
  end

  def test_add_system_groups
    expected_ids = @system_groups.collect {|group| group.id}
    post :add_system_groups, :id => @system.uuid, :system => {
        :system_group_ids => expected_ids
    }

    assert_response :success
    assert_template 'api/v2/systems/add_system_groups'
    assert_equal @system.system_group_ids, expected_ids
  end

  def test_add_system_groups_empty
    expected_ids = []
    post :add_system_groups, :id => @system.uuid, :system => {
        :system_group_ids => expected_ids
    }

    assert_response :success
    assert_template 'api/v2/systems/add_system_groups'
    assert_equal @system.system_group_ids, expected_ids
  end

  def test_add_system_groups_nil
    post :add_system_groups, :id => @system.uuid, :system => {
        :system_group_ids => nil
    }

    assert_response :success
    assert_template 'api/v2/systems/add_system_groups'
    assert_equal @system.system_group_ids, []
  end

end
