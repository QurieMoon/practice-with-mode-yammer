-- PostgreSQL

-- 상태(state)별 사용자 수
SELECT COUNT(DISTINCT CASE WHEN tutorial.yammer_users.state = 'active' THEN tutorial.yammer_users.user_id END) AS num_active_users
     , COUNT(DISTINCT CASE WHEN tutorial.yammer_users.state = 'pending' THEN tutorial.yammer_users.user_id END) AS num_pending_users
FROM tutorial.yammer_events
     LEFT JOIN tutorial.yammer_users ON tutorial.yammer_events.user_id = tutorial.yammer_users.user_id

-- 월별 사용자 수
SELECT EXTRACT(MONTH FROM tutorial.yammer_events.occurred_at) AS event_month
     , COUNT(DISTINCT tutorial.yammer_events.user_id) AS num_monthly_users
FROM tutorial.yammer_events
    LEFT JOIN tutorial.yammer_users ON tutorial.yammer_events.user_id = tutorial.yammer_users.user_id
GROUP BY event_month

-- 이벤트 타입별 사용자 수 (가입자 수, 활동자 수 확인)
SELECT EXTRACT(MONTH FROM tutorial.yammer_events.occurred_at) AS event_month
     , COUNT(DISTINCT CASE WHEN tutorial.yammer_events.event_type = 'signup_flow' THEN tutorial.yammer_events.user_id END) AS num_monthly_signup_users
     , COUNT(DISTINCT CASE WHEN tutorial.yammer_events.event_type = 'engagement' THEN tutorial.yammer_events.user_id END) AS num_monthly_engagement_users
FROM tutorial.yammer_events
    LEFT JOIN tutorial.yammer_users ON tutorial.yammer_events.user_id = tutorial.yammer_users.user_id
GROUP BY event_month
ORDER BY event_month ASC

-- 월별 engagement / signup_flow / signup 사용자 수
WITH user_signup_info_tbl AS (
  SELECT DISTINCT user_id
       , EXTRACT(MONTH FROM tutorial.yammer_events.occurred_at) AS signup_month
  FROM tutorial.yammer_events
  WHERE tutorial.yammer_events.event_name = 'complete_signup'
)

SELECT EXTRACT(MONTH FROM tutorial.yammer_events.occurred_at) AS event_month
     , COUNT(DISTINCT CASE WHEN tutorial.yammer_events.event_type = 'engagement' THEN tutorial.yammer_events.user_id END) AS num_monthly_engagement_users
     , COUNT(DISTINCT CASE WHEN tutorial.yammer_events.event_name = 'complete_signup' THEN tutorial.yammer_events.user_id END) AS num_monthly_signup_users
     , COUNT(DISTINCT CASE WHEN tutorial.yammer_events.event_type = 'engagement' AND EXTRACT(MONTH FROM tutorial.yammer_events.occurred_at) = user_signup_info_tbl.signup_month THEN tutorial.yammer_events.user_id END) AS num_monthly_engagement_new_users
FROM tutorial.yammer_events
    LEFT JOIN tutorial.yammer_users ON tutorial.yammer_events.user_id = tutorial.yammer_users.user_id
    LEFT JOIN user_signup_info_tbl ON tutorial.yammer_events.user_id = user_signup_info_tbl.user_id
GROUP BY event_month
ORDER BY event_month ASC

-- 언어별 사용자 수
SELECT tutorial.yammer_users.language AS language
     , COUNT(DISTINCT tutorial.yammer_events.user_id) AS num_users_per_language
FROM tutorial.yammer_events
    LEFT JOIN tutorial.yammer_users ON tutorial.yammer_events.user_id = tutorial.yammer_users.user_id
GROUP BY language
ORDER BY num_users_per_language DESC;

-- 월별 발생 이벤트 구성 비율
SELECT EXTRACT(MONTH FROM tutorial.yammer_events.occurred_at) AS event_month
     , COUNT(CASE WHEN event_type = 'signup_flow' THEN occurred_at END) AS num_signup_flow_events
     , COUNT(CASE WHEN event_type = 'engagement' THEN occurred_at END) AS num_engagement_events
     , ROUND(COUNT(CASE WHEN event_type = 'engagement' THEN occurred_at END)/CAST(COUNT(*) AS DECIMAL)*100, 2) AS engagement_ratio
FROM tutorial.yammer_events
GROUP BY event_month
ORDER BY event_month ASC;

-- engagement에 속하는 event_name 구성 비율
SELECT DISTINCT event_name
     , COUNT(occurred_at) AS num_events
FROM tutorial.yammer_events
WHERE event_type = 'engagement'
GROUP BY event_name
ORDER BY num_events DESC;

-- 나라별 engagment 이벤트 발생 비율
SELECT location
     , COUNT(occurred_at) AS num_events
     , ROUND(CAST(COUNT(occurred_at) AS DECIMAL)/(
       SELECT COUNT(*)
       FROM tutorial.yammer_events
       WHERE tutorial.yammer_events.event_type = 'engagement'
     )*100, 2) AS num_events_ratio
FROM tutorial.yammer_events
WHERE tutorial.yammer_events.event_type = 'engagement'
GROUP BY location
ORDER BY num_events_ratio DESC;

