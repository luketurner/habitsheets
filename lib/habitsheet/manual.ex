defmodule Habitsheet.Manual do
  def load_manpage(manpage) do
    manpage_dir = Application.app_dir(:habitsheet, "priv/manpage")
    manpage_file = "#{manpage}.md"
    # TODO -- avoid running ls on every request
    valid_files = File.ls!(manpage_dir)

    # An allow-list of valid files is used to prevent attacks with ..
    if Enum.member?(valid_files, manpage_file) do
      Earmark.from_file!(Path.join(manpage_dir, manpage_file))
    else
      "Unknown manpage"
    end
  end
end
