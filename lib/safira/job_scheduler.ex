defmodule Safira.JobScheduler do
  @moduledoc false
  use Quantum, otp_app: :safira

  import Crontab.CronExpression

  alias Safira.Jobs

  def init(opts) do
    Keyword.put(opts, :jobs, load_jobs())
  end

  # FIXME: These are only examples. Should be updated to the real jobs, with the correct parameters
  # and should be set to active (refer to create_job/4 function)
  defp load_jobs do
    [
      create_job(:daily_badge, ~e[0 * * * *], {Jobs.DailyBadge, :run, [123, "2023-12-01"]}),
      create_job(:all_gold_badge, ~e[5 * * * *], {Jobs.AllGoldBadge, :run, [123]}),
      create_job(
        :full_participation_badge,
        ~e[10 * * * *],
        {Jobs.FullParticipationBadge, :run, [123]}
      ),
      create_job(
        :participate_in_two_days,
        ~e[15 * * * *],
        {Jobs.ParticipationBadge, :run, [123, 2]}
      ),
      create_job(
        :redeem_fifty_badges,
        ~e[25 * * * *],
        {Jobs.CheckpointBadge, :run, [123, 50, 0]}
      ),
      create_job(
        :attend_three_workshops,
        ~e[30 * * * *],
        {Jobs.CheckpointBadge, :run, [123, 3, 7]}
      ),
      create_job(
        :visit_twenty_booths,
        ~e[20 * * * *],
        {Jobs.CheckpointBadgeWithRedeemable, :run, [123, 20, 4, 30, 456]}
      )
    ]
  end

  defp create_job(name, schedule, task, state \\ :inactive) do
    Safira.JobScheduler.new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(task)
    |> Quantum.Job.set_state(state)
  end
end
