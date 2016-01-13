# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2011-2015 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

#custom routes for this plugin

resources :leads do
  collection do
    get :bulk_edit, :context_menu, :edit_mails, :contacts_notes
    post :bulk_edit, :bulk_update, :send_mails, :preview_email
    delete :bulk_destroy
  end
  member do
    get 'tabs/:tab' => 'leads#show', :as => "tabs"
    get 'load_tab' => 'leads#load_tab', :as => "load_tab"
  end
  resources :contacts_projects, :path => "projects", :only => [:new, :create, :destroy]
end

resources :projects do
  resources :leads do
    collection do
      get :contacts_notes, :search_existance
    end
  end


end