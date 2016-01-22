require_dependency 'crm_queries_helper'

module  RedmineLeads
  module CrmQueriesHelperPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        def crm_query_links2(title, queries, object_type)
          # links to #index on contacts/show
          return '' unless queries.any?
          url_params = controller_name == "#leads" ? {:controller => "#leadss", :action => 'index', :project_id => @project} : params
          content_tag('h3', title) + "\n" +
              content_tag('ul',
                          queries.collect {|query|
                            css = 'query'
                            css << ' selected' if query == @query
                            content_tag('li', link_to(query.name, url_params.merge(:query_id => query), :class => css))
                          }.join("\n").html_safe,
                          :class => 'queries'
              ) + "\n"
        end

        def render_sidebar_crm_queries2(object_type)
          query_class = Object.const_get("#{object_type.camelcase}Query")
          out = ''.html_safe
          out << crm_query_links2(l(:label_my_queries), sidebar_crm_queries(query_class).select(&:is_private?), object_type)
          out << crm_query_links2(l(:label_query_plural), sidebar_crm_queries(query_class).reject(&:is_private?), object_type)
          out
        end
      end
    end
  end
  module ClassMethods
  end

  module InstanceMethods

  end
end

