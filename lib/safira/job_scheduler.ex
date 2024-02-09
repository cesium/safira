defmodule Safira.JobScheduler do
  @moduledoc false
  use Quantum, otp_app: :safira

  import Crontab.CronExpression

  alias Safira.Jobs

  def init(opts) do
    Keyword.put(opts, :jobs, load_jobs())
  end

  defp load_jobs do
    [
      create_job(
        :day1_badge,
        ~e[0 * * * *],
        {Jobs.DailyBadge, :run, [206, "2024-02-06"]}
      ),
      create_job(
        :day2_badge,
        ~e[1 * * * *],
        {Jobs.DailyBadge, :run, [207, "2024-02-07"]}
      ),
      create_job(
        :day3_badge,
        ~e[2 * * * *],
        {Jobs.DailyBadge, :run, [208, "2024-02-08"]}
      ),
      create_job(
        :day4_badge,
        ~e[3 * * * *],
        {Jobs.DailyBadge, :run, [209, "2024-02-09"]}
      ),
      create_job(
        :all_days_badge,
        ~e[4 * * * *],
        {Jobs.FullParticipationBadge, :run, [210]}
      ),
      create_job(
        :redeem_100_badges,
        ~e[5 * * * *],
        {Jobs.CheckpointBadge, :run, [211, 100, 0]}
      ),
      create_job(
        :all_talks,
        ~e[6 * * * *],
        {Jobs.CheckpointBadge, :run, [212, 13, 6, 0]}
      ),
      create_job(
        :three_workshops,
        ~e[7 * * * *],
        {Jobs.CheckpointBadge, :run, [213, 3, 7, 0]}
      ),
      create_job(
        :all_pitches,
        ~e[8 * * * *],
        {Jobs.CheckpointBadge, :run, [214, 8, 9, 0]}
      ),
      create_job(
        :two_days,
        ~e[9 * * * *],
        {Jobs.ParticipationBadge, :run, [222, 2]}
      ),
      create_job(
        :all_badges,
        ~e[10 * * * *],
        {Jobs.CheckpointBadge, :run, [224, 126, 0]}
      ),
      create_job(
        :gambling_addiction,
        ~e[11 * * * *],
        {Jobs.GamblingAddiction, :run, [234]}
      ),
      create_job(
        :all_gold,
        ~e[12 * * * *],
        {Jobs.AllGoldBadge, :run, [241]}
      ),
      create_job(
        :visit_five_booths,
        ~e[20 * * * *],
        {Jobs.CheckpointBadge, :run, [235, 5, 4, 10]}
      ),
      create_job(
        :visit_ten_booths,
        ~e[21 * * * *],
        {Jobs.CheckpointBadge, :run, [236, 10, 4, 30]}
      ),
      create_job(
        :visit_fifteen_booths,
        ~e[22 * * * *],
        {Jobs.CheckpointBadge, :run, [237, 15, 4, 60]}
      ),
      create_job(
        :visit_twenty_booths,
        ~e[23 * * * *],
        {Jobs.CheckpointBadge, :run, [238, 20, 4, 100]}
      ),
      create_job(
        :visit_twenty_five_booths,
        ~e[24 * * * *],
        {Jobs.CheckpointBadge, :run, [239, 25, 4, 120]}
      ),
      create_job(
        :visit_all_booths,
        ~e[25 * * * *],
        {Jobs.CheckpointBadge, :run, [240, 29, 4, 150]}
      ),
      create_job(
        :upload_cv,
        ~e[26 * * * *],
        {Jobs.CVBadge, :run, [294]}
      ),
      create_job(
        :spotlight,
        ~e[27 * * * *],
        {Jobs.SpotlightBadge, :run, [242]}
      )
    ]
  end

  defp create_job(name, schedule, task, state \\ :active) do
    Safira.JobScheduler.new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_schedule(schedule)
    |> Quantum.Job.set_task(task)
    |> Quantum.Job.set_state(state)
  end
end
