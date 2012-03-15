Deface::Override.new(:virtual_path => "layouts/admin",
        :name => "Add Froomerce tab to menu",
        :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
        :text => " <%= tab :froomerces, :css_class => ( params[:controller] == 'admin/froomerces' ) ? 'selected' : '' %>",
        :disabled => false)