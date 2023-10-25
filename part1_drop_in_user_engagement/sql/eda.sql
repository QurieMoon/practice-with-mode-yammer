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

