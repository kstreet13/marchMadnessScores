# marchMadnessScores

If you're like me and you occasionally find yourself wishing you had a nicely formatted database of every (men's) March Madness game, here you go! I think I managed to find every game since the field expanded to 64 teams in 1985, up through 2024 (because the NCAA hasn't updated their website to include complete 2025 data as of the time I'm writing this).

Since brackets are a highly-structured type of data, it's not easy to find traditional "tidy" datasets for the tournament, even though all the information is definitely out there. And since the tournament poses a famously challenging prediction problem, I imagine I'm not the only person interested in this data for stats-y reasons.

Most of these results are directly from the NCAA's website (see links in `getData.R`), with certain typos/missing data amended by manual inspection with help from Wikipedia, ESPN.com, and sports-reference.com.

Here's the data format, with the winning team listed as `team1`:
| seed1 | team1 | score1 | seed2 | team2 | score2 | round | year |
|-------|-------|--------|-------|-------|--------|-------|------|
| 1 | Georgetown |  68 | 16 | Lehigh | 43 | 64 | 1985 |
| 8 | Temple | 60 | 9 | Virginia Tech | 57 | 64 | 1985 |
| 5 | SMU | 85 | 12 | Old Dominion | 68 | 64 | 1985 |

I should note that I am not affiliated with nor endorsed by the NCAA, so this repository may disappear without warning.

## FAQ

### Is the data reliable?
I think so! Like I said, most of it is from the NCAA's website and on top of that, I ran several checks for internal consistency (such as: making sure there are the right number of teams, that all the first round matchups feature valid combinations of seeds, that losing teams don't show up later in the tournament, etc.). The original data contained a fair number of typos, but I think I managed to catch most of them.

### Is the data consistent from year to year?
Not necessarily! I checked each year for internal consistency, so a team is never referenced by multiple names within a given year, but it's entirely possible that (eg.) UC Berkeley is listed as "Cal" one year and "California" another.

### What if I find an error in the data?
Please let me know! I want this to be a useful resource for people, so if you find a problem, please open an issue in the Issues tab.

### Are you gonna collect results for the women's tournament?
Yes! Unfortunately, the NCAA's website is not as thorough when it comes to women's basketball history, so this requires a little more effort, but it's very much on my to-do list.

### Are play-in (or "First Four") games included?
Yes! Games that take place before the Round of 64 are categorized as round `0`.

### Why not just use the Kaggle dataset?
Because it only goes back to 2008 and I'm a completionist.

### I want more rankings/stats so that I can build a prediction model.
That's not a question and it's also not the point of this repository.

### What about the 2021 game between #7 Oregon and #10 VCU?
Look. Some tough decisions had to be made. That game was declared a no-contest due to COVID-19 protocols and Oregon advanced automatically. I could either write two sets of tests, one for every year except 2021 where we assume 32 games in the first round and another for 2021 where we assume 31, or I could encode that game as a 0-0 "win" for Oregon. I took the easier route, which is why there's exactly one game where `team1`'s score is not greater than `team2`'s score.
