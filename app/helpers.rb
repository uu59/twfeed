class MyApp
  module Helpers
    def tr(label, name, default=nil)
      tpl = <<-HTML
      <tr>
        <th><%== label %></th>
        <td>
        <input type="text" name="<%== name %>" value="<%== default || params[name] %>" />
        </td>
      </tr>
      HTML
      erb = Erubis::Eruby.new(tpl)
      erb.result(binding())
    end
  end

  helpers Helpers
end
