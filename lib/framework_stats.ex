defmodule FrameworkStats do
  # popular frameworks
  @frameworks [
    "rails/rails",
    "phoenixframework/phoenix",
    "playframework/playframework",
    "expressjs/express",
    "revel/revel",
    "django/django",
    "meteor/meteor",
    "symfony/symfony",
    "kraih/mojo"
  ]

  def report do
    IO.puts "## Framework: open issues/all issues (percentage)"
    Enum.map(@frameworks, fn(repo) ->
      FrameworkStats.GithubIssues.get_stats(repo)
      |> convert_stats(repo)
    end)
    |> Enum.filter(&(&1!=nil))
    |> Enum.sort(fn(s1, s2) -> s1[:rate] < s2[:rate] end)
    |> Enum.map(&format_stats/1)
    |> Enum.join("\n")
    |> IO.puts

    IO.puts "(Including pull requests)"
  end

  defp convert_stats(%{all_issues: 0}, _) do
    nil
  end

  defp convert_stats(stats, repo) do
    Map.merge(stats, %{
      rate: stats[:open_issues] / stats[:all_issues],
      repo: repo
    })
  end

  defp add_rate(stats) do
    Map.marge(stats, %{rate: stats[:open_issues] / stats[:all_issues]})
  end

  def format_stats(%{open_issues: open, all_issues: all, rate: rate, repo: repo}) do
    percent = Float.round(rate * 100.0, 2)
    "- [#{repo}](#{url(repo)}): #{open}/#{all} (#{percent}%)"
  end

  def url(repo) do
    "https://github.com/#{repo}"
  end
end
