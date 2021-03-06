require File.expand_path('../../test_helper', __FILE__)
require File.expand_path('../../../lib/view_customize/view_hook', __FILE__)

class ViewCustomizeViewHookTest < ActiveSupport::TestCase
  fixtures :view_customizes, :projects, :users, :issues, :custom_fields, :custom_values

  class Request
    def initialize(path)
      @path = path
    end

    def path_info
      @path
    end
  end

  def setup
    @project_ecookbook = Project.find(1)
    @project_onlinestore = Project.find(2)
    @hook = RedmineViewCustomize::ViewHook.instance
  end

  def test_match_customize

    User.current = User.find(1)

    matches = @hook.send(:match_customize, {:request => Request.new("/")}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [2], matches.map {|x| x.id }

    # path pattern
    matches = @hook.send(:match_customize, {:request => Request.new("/issues")}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [1, 2], matches.map {|x| x.id }

    matches = @hook.send(:match_customize, {:request => Request.new("/issues/1")}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [2], matches.map {|x| x.id }

    # project pattern
    matches = @hook.send(:match_customize, {:request => Request.new("/issues"), :project => @project_ecookbook}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [1, 2, 3], matches.map {|x| x.id }

    matches = @hook.send(:match_customize, {:request => Request.new("/issues"), :project => @project_onlinestore}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [1, 2], matches.map {|x| x.id }

    # path and project pattern
    matches = @hook.send(:match_customize, {:request => Request.new("/issues/new"), :project => @project_ecookbook}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [2, 3, 4], matches.map {|x| x.id }

    # private
    User.current = User.find(2)
    matches = @hook.send(:match_customize, {:request => Request.new("/")}, ViewCustomize::INSERTION_POSITION_HTML_HEAD)
    assert_equal [2, 6], matches.map {|x| x.id }

    # insertion position
    matches = @hook.send(:match_customize, {:request => Request.new("/issues")}, ViewCustomize::INSERTION_POSITION_ISSUE_FORM)
    assert_empty matches

    matches = @hook.send(:match_customize, {:request => Request.new("/issues/new"), :project => @project_ecookbook}, ViewCustomize::INSERTION_POSITION_ISSUE_FORM)
    assert_equal [7], matches.map {|x| x.id }
    matches = @hook.send(:match_customize, {:request => Request.new("/issues/new"), :project => @project_onlinestore}, ViewCustomize::INSERTION_POSITION_ISSUE_FORM)
    assert_equal [7], matches.map {|x| x.id }

    matches = @hook.send(:match_customize, {:request => Request.new("/issues/123"), :project => @project_onlinestore}, ViewCustomize::INSERTION_POSITION_ISSUE_SHOW)
    assert_equal [8], matches.map {|x| x.id }

  end

  def test_view_layouts_base_html_head

    User.current = User.find(1)

    expected = <<HTML

<!-- [view customize plugin] path:/issues -->
<link rel=\"stylesheet\" media=\"screen\" href=\"/plugin_assets/view_customize/stylesheets/view_customize.css?1592744523\" /><script type=\"text/javascript\">
//<![CDATA[
ViewCustomize = { context: {\"user\":{\"id\":1,\"login\":\"admin\",\"admin\":true,\"firstname\":\"Redmine\",\"lastname\":\"Admin\",\"lastLoginOn\":\"2006-07-19T20:57:52Z\",\"groups\":[],\"apiKey\":null,\"customFields\":[{\"id\":4,\"name\":\"Phone number\",\"value\":null},{\"id\":5,\"name\":\"Money\",\"value\":null}]},\"project\":{\"identifier\":\"ecookbook\",\"name\":\"eCookbook\",\"roles\":[{\"id\":1,\"name\":\"Non member\"}],\"customFields\":[{\"id\":3,\"name\":\"Development status\",\"value\":\"Stable\"}]}} };
//]]>
</script>
<!-- view customize id:1 -->
<script type=\"text/javascript\">
//<![CDATA[
code_001
//]]>
</script>
<!-- view customize id:2 -->
<style type=\"text/css\">
code_002
</style>
<!-- view customize id:3 -->
code_003
HTML

    html = @hook.view_layouts_base_html_head({:request => Request.new("/issues"), :project => @project_ecookbook})
    assert_equal expected, html

  end

  def test_view_issues_form_details_bottom

    User.current = User.find(1)

    expected = <<HTML

<!-- view customize id:7 -->
code_007
HTML

    html = @hook.view_issues_form_details_bottom({:request => Request.new("/issues/new"), :project => @project_ecookbook})
    assert_equal expected, html

  end

  def test_view_issues_show_details_bottom

    User.current = User.find(1)
    issue = Issue.find(1)

    expected = <<HTML

<script type=\"text/javascript\">
//<![CDATA[
ViewCustomize.context.issue = { id: 1 };
//]]>
</script>
<!-- view customize id:8 -->
<style type=\"text/css\">
code_008
</style>
HTML

    html = @hook.view_issues_show_details_bottom({:request => Request.new("/issues/1"), :issue => issue, :project => @project_onlinestore})
    assert_equal expected, html

  end

end
