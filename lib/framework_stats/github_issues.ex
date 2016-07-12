defmodule FrameworkStats.GithubIssues do
  @headers [ { "User-agent", "github.com/ono/framework_stats" } ]

  def get_stats(repo) do
    open = get_count(repo, "open")
    all = get_count(repo, "all")

    %{open_issues: open, all_issues: all}
  end

  def get_count(repo, state) do
    issues_url(repo, state)
    |> HTTPoison.get(@headers)
    |> retrieve_link_header
    |> retrieve_count
  end

  defp issues_url(repo, state) do
    "https://api.github.com/repos/#{repo}/issues?state=#{state}&per_page=1"
  end

  defp retrieve_count({"Link", link}) do
    # Take 25771 from...
    # [["page=1", "1"], ["page=2", "2"], ["page=1", "1"], ["page=25771","25771"]]
    {count, _} = Regex.scan(~r/page=([0-9]+)/, link)
      |> Enum.at(-1)
      |> Enum.at(-1)
      |> Integer.parse
    count
  end

  defp retrieve_count(_) do
    0
  end

  defp retrieve_link_header({:ok, %{status_code: 200, headers: headers}}) do
    Enum.find(headers, fn(h) -> elem(h, 0) == "Link" end)
  end

  defp retrieve_link_header(_) do
    nil
  end
end
