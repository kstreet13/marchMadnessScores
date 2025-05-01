# marchMadnessScores

**Main data files: `mensResults.csv`, `womensResults.csv`**

If you're like me and you occasionally find yourself wishing you had a nicely formatted database of every March Madness game, here you go! I think I managed to find every game since the field expanded to 64 teams (1985 for the men, 1994 for the women). All data is scraped from Wikipedia and runs through 2025.

The data contains one row per game and the winning team is always listed as `team1`. Here's a sample of the format:
| seed1 | team1 | score1 | seed2 | team2 | score2 | round | year |
|-------|-------|--------|-------|-------|--------|-------|------|
| 1 | Georgetown |  68 | 16 | Lehigh | 43 | 64 | 1985 |
| 8 | Temple | 60 | 9 | Virginia Tech | 57 | 64 | 1985 |
| 5 | SMU | 85 | 12 | Old Dominion | 68 | 64 | 1985 |

I should note that I am not affiliated with nor endorsed by the NCAA, so this repository may disappear without warning.

## FAQ

### Why do this?
Even though all this information already exists on the internet, it's not easy to find a traditional "tidy" dataset for these tournaments, in part because brackets represent a very specific, highly-structured type of data. However, the tournament also poses a famously challenging prediction problem, so I know I'm not the only person interested in this data for stats-y reasons.

### Where did the data come from?
All results were scraped from Wikipedia, which seems to be more consistent and contain fewer typos than the records on the NCAA's website.

### Is the data reliable?
I think so! I ran several checks for internal consistency (such as: making sure there are the right number of teams, that all the first round matchups feature valid combinations of seeds, that losing teams don't show up later in the tournament, etc.). I also manually verified that each year contained the right number of teams/games, since the field has expanded to 68 teams in recent years.

### Is the data consistent from year to year?
Not necessarily! I checked each year for internal consistency, so a team is never referenced by multiple names within a given year, but it's entirely possible that (eg.) UC Berkeley is listed as "Cal" one year and "California" another ("State" vs. "St." is a likely change, as well).

### What if I find an error in the data?
Please let me know! I want this to be a useful resource for people, so if you find a problem, please open an issue in the Issues tab.

### Are play-in (or "First Four") games included?
Yes! Games that take place before the Round of 64 are categorized as round `0`.

### Why not just use the Kaggle dataset?
Because it only goes back to 2008 and doesn't include the women's tournaments.

### I want more rankings/stats so that I can build a prediction model.
That's not a question and it's also not the point of this repository.

### What about the 2021 men's game between #7 Oregon and #10 VCU?
Look. Some tough decisions had to be made. That game was declared a no-contest due to COVID-19 protocols and Oregon advanced automatically. I could either write two sets of tests, one for every year except 2021 where we assume 32 games in the first round and another for 2021 where we assume 31, or I could encode that game as a 0-0 "win" for Oregon. I took the easier route, which is why there's exactly one game where `team1`'s score is equal to `team2`'s score.
