/* 
1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.
2. Display the number of matches conducted at each stadium with stadium name, city from the database.
3. In a given stadium, what is the percentage of wins by a team which has won the toss?
4. Show the total bids along with bid team and team name.
5. Show the team id who won the match as per the win details.
6. Display total matches played, total matches won and total matches lost by team along with its team name.
7. Display the bowlers for Mumbai Indians team.
8. How many all-rounders are there in each team, Display the teams with more than 4 
all-rounder in descending order.*/

-- 1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select bd.BIDDER_ID,bd.BIDDER_NAME,bp.NO_OF_BIDS,
count(bid.BID_STATUS)Won_Bids,
concat(round(count(bid.BID_STATUS)/bp.NO_OF_BIDS,2)*100,'%')Win_pct
from IPL_BIDDER_DETAILS bd
left join IPL_BIDDING_DETAILS bid
on bd.BIDDER_ID=bid.BIDDER_ID
left join IPL_BIDDER_POINTS bp
on bd.BIDDER_ID=bp.BIDDER_ID
where bid.BID_STATUS = 'Won'
group by bd.BIDDER_ID,bd.BIDDER_NAME,bp.NO_OF_BIDS
order by count(bid.BID_STATUS)/bp.NO_OF_BIDS desc ;


# 2. Display the number of matches conducted at each stadium with stadium name, city from the database.

select ms.stadium_id,s.stadium_name,s.CITY , count(ms.stadium_id)Matches_Played
from IPL_MATCH_SCHEDULE ms
join IPL_STADIUM s
on ms.STADIUM_ID = s.STADIUM_ID
group by ms.stadium_id,s.stadium_name,s.CITY
order by ms.stadium_id ;

# 3. In a given stadium, what is the percentage of wins by a team which has won the toss?

select stadium_id,stadium_name,
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;

# 4. Show the total bids along with bid team and team name.

select TEAM_ID,TEAM_NAME,count(BID_TEAM)Total_Bids
from IPL_TEAM t
join IPL_BIDDING_DETAILS bd
on TEAM_ID = BID_TEAM
group by TEAM_ID,BID_TEAM,TEAM_NAME
order by TEAM_ID;

# 5. Show the team id who won the match as per the win details.

select MATCH_ID,
case 
when MATCH_WINNER =1 then TEAM_ID1
when MATCH_WINNER =2 then TEAM_ID2
else MATCH_WINNER end Winner_Team
from IPL_MATCH;

# 6. Display total matches played, total matches won and total matches lost by team along with its team name.

select ts.TEAM_ID,TEAM_NAME,ts.TOURNMT_ID,MATCHES_PLAYED,MATCHES_WON,MATCHES_LOST
from IPL_TEAM_STANDINGS ts
join IPL_TEAM t
on ts.TEAM_ID = t.TEAM_ID;

# 7. Display the bowlers for Mumbai Indians team.

select TEAM_ID,PLAYER_ID,PLAYER_ROLE
from IPL_TEAM_PLAYERS
where TEAM_ID = 5 and PLAYER_ROLE = 'Bowler';

-- -----------------------------------------------------------
														  -- |
select REMARKS,PLAYER_ID,PLAYER_ROLE                      -- |
from IPL_TEAM_PLAYERS                                     -- |
where REMARKS = 'TEAM - MI' and PLAYER_ROLE = 'Bowler';   -- |
                                                          -- |
-- -----------------------------------------------------------                                                          

# 8. How many all-rounders are there in each team, Display the teams with more than 4 
-- all-rounder in descending order.

select tp.TEAM_ID,t.TEAM_NAME,PLAYER_ROLE,count(PLAYER_ROLE)No_Of_Plyaers
from IPL_TEAM_PLAYERS tp
join IPL_TEAM t
on tp.TEAM_ID = t.TEAM_ID
where PLAYER_ROLE = 'All-Rounder'
group by tp.TEAM_ID,PLAYER_ROLE
having No_Of_Plyaers>4
order by No_Of_Plyaers desc;
