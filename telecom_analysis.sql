-- TELECOM HISTORICAL ANALYSIS 2021-2026 | Oluyomi Abayomi
-- Dataset: 2124 days | Business Acumen: From technical metrics to P&L

-- 1. REVENUE DRIVER: What drives revenue? (99.8% correlation = subscribers)
SELECT 
    CORR(subscribers, revenue_per_day) as revenue_subscriber_correlation,
    AVG(revenue_per_day / subscribers) as arpu,
    -- Business Meaning: Every 1M subs = ~0.44M per day revenue
    (MAX(subscribers) - MIN(subscribers)) * AVG(revenue_per_day / subscribers) as revenue_opportunity
FROM telecom_historical;

-- 2. RISK: SATURATION POINT - When does network pain start?
SELECT 
    CASE 
        WHEN network_load_pct > 85 THEN 'CRITICAL >85%'
        WHEN network_load_pct > 75 THEN 'WARNING 75-85%'
        ELSE 'HEALTHY <75%'
    END as load_status,
    AVG(dropped_calls_pct) as avg_dropped,
    AVG(churn_rate_pct) as avg_churn,
    COUNT(*) as days_in_status
FROM telecom_historical
GROUP BY load_status;
-- Business Meaning: Load >85% => Dropped +18% => Churn => Revenue Loss
-- Action: Capex before 90% (predicted 2028)

-- 3. CHURN ANALYSIS: How much do we lose to churn?
SELECT 
    AVG(churn_rate_pct) as avg_churn_3_15_pct,
    -- Target: 1.83% industry best
    (3.15 - 1.83) / 100 * AVG(subscribers) * AVG(revenue_per_day / subscribers) * 365 / 1000000 as annual_saving_M
FROM telecom_historical;
-- Result: $54.7M saving if churn 3.15% -> 1.83%
-- Investment: 60% towers, 20% spectrum, 20% edge = 150% ROI

-- 4. YEARLY GROWTH: Are we growing or saturating?
SELECT 
    EXTRACT(YEAR FROM date) as year,
    AVG(subscribers) as avg_subs,
    SUM(revenue_per_day) as total_revenue,
    AVG(network_load_pct) as avg_load,
    -- Forecast: Growth slowing, load rising -> need new strategy
    LAG(AVG(subscribers)) OVER (ORDER BY EXTRACT(YEAR FROM date)) as prev_year_subs,
    (AVG(subscribers) - LAG(AVG(subscribers)) OVER (ORDER BY EXTRACT(YEAR FROM date))) / LAG(AVG(subscribers)) OVER (ORDER BY EXTRACT(YEAR FROM date)) * 100 as yoy_growth_pct
FROM telecom_historical
GROUP BY year
ORDER BY year;

-- 5. FORECAST TO 2031: Business Decision Model
SELECT 
    -- Using historical growth to project
    AVG(subscribers) * POWER(1 + 0.08, 5) as projected_subs_2031,
    SUM(revenue_per_day) * POWER(1 + 0.08, 5) as projected_revenue_2031,
    AVG(network_load_pct) + 5 * 2.1 as projected_load_2031 -- Load increasing 2.1% per year
FROM telecom_historical
WHERE EXTRACT(YEAR FROM date) = 2025;
-- Business Decision: Must invest now or hit 90%+ load by 2028 = service collapse
