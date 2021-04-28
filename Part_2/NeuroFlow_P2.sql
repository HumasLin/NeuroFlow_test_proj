-- Q1: the percentage of users that have a completed exercise in their first month for each monthly cohort

SELECT CONCAT('the ',YearMonth,' cohort has ',res,'% of users completing an exercise in their first month') 
AS report
FROM
(SELECT CAST(CAST(100*SUM(attend) AS FLOAT)/CAST(COUNT(*) AS FLOAT) AS decimal(10,2)) AS res, 
YearMonth
FROM
(SELECT UID,YearMonth,
	CASE WHEN SUM(match) > 0
    	THEN 1
        ELSE 0
    END
AS attend
FROM
(SELECT U.user_id AS UID, FORMAT(U.created_at,'y') AS YearMonth, 
	CASE WHEN FORMAT(U.created_at,'y') = FORMAT(E.exercise_completion_date,'y')
		THEN 1 
		ELSE 0
	END 
AS match
FROM 
users U JOIN exercises E
on U.user_id = E.user_id) AS combination # flag whether an excercise is taken in the first month
GROUP BY UID,YearMonth) AS integrate # make sure one user is counted only once
GROUP BY YearMonth) AS results # compute the percentage of qualified users by month
ORDER BY YEAR(YearMonth),MONTH(YearMonth);

-- Q2: a frequency distribution of the number of activities each user completed

SELECT CONCAT(num_user,' users completed ',num_act,' activity') AS report
FROM
(SELECT count(*) AS num_user,num_act FROM
(SELECT count(*) AS num_act,user_id FROM 
exercises
GROUP BY user_id) AS excercise_complete # count number of excercises one user completed
GROUP BY num_act) AS user_frequency # count number of users that completed certain number of excercises
ORDER BY num_customer;

-- Q3: the top five organizations that have the highest average phq9 score per patient
-- I assume the question is to find the top 5 organizations with highest average phq9 score per patient
-- regardless of whether the phq9 score is above 20 ("severe") or not.

-- If we need to only keep phq9 scores larger than 20, we can add a WHERE-clause in the nested query

SELECT TOP 5 AVG(avg_patient) AS avg_organization, OrgID
FROM
(SELECT P9.patient_id AS PID, P.organization_id AS OrgID, AVG(Price) AS avg_patient FROM 
Providers P join Phq9 P9
on P.provider_id = P9.provider_id
GROUP BY PID, OrgID) AS patient_avg # assume each patient can have multiple Phq9 records
GROUP BY OrgID
ORDER BY avg_organization DESC;
