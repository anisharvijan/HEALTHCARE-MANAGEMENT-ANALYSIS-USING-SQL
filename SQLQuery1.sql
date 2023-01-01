--Select*
--from diabetic_data$

--Task 1: The health care management wants to know the distribution of time spent in the hospital in general.

SELECT ROUND(time_in_hospital,1) as total_days, COUNT(*) as count,
       REPLICATE('*', CAST(count(*) AS INT)/100) as bar
FROM diabetic_data$
GROUP BY ROUND(time_in_hospital,1)
ORDER BY total_days;

--TASK 2: Budget management- A brand-new hospital director wants a list of all specialties and the average total of the number of procedures currently practiced at the hospital.

SELECT DISTINCT medical_specialty, COUNT(medical_specialty) as total, 
        ROUND (AVG(num_procedures),1) as average_procedures
FROM diabetic_data$
WHERE medical_specialty IS NOT NULL AND medical_specialty != '?'
GROUP BY medical_specialty
ORDER BY average_procedures DESC

--the management then wanted the specialties with at least 50 patients and more than 2.5 procedures on average.

SELECT medical_specialty, COUNT(medical_specialty) as total, 
       ROUND (AVG(num_procedures),1) as average_procedures
FROM diabetic_data$
WHERE medical_specialty IS NOT NULL AND medical_specialty != '?'
GROUP BY medical_specialty
HAVING  COUNT(medical_specialty) > 50 AND ROUND (AVG(num_procedures),1)  > 2.5
ORDER BY average_procedures DESC

--TASK 3: Integrity- The Chief of Nursing wants to know if the hospital seems to be treating patients of different races differently, specifically with the number of lab procedures done.

SELECT race, AVG(num_lab_procedures) as avg_procedures
FROM diabetic_data$
WHERE race IS NOT NULL AND race != '?'
GROUP BY race
ORDER BY avg_procedures DESC

--to divide the patients into groups based on the number of lab procedures performed.
--SELECT race,
--       AVG(num_lab_procedures) as avg_procedures,
--       AVG(CASE WHEN num_lab_procedures <= 3 THEN 1 ELSE 0 END) as low_procedures,
--       AVG(CASE WHEN num_lab_procedures > 3 AND num_lab_procedures <= 6 THEN 1 ELSE 0 END) as medium_procedures,
--       AVG(CASE WHEN num_lab_procedures > 6 THEN 1 ELSE 0 END) as high_procedures
--FROM diabetic_data$
--GROUP BY race
--ORDER BY avg_procedures DESC

--TASK 4: Do people need more procedures if they stay longer in the hospital?

SELECT MIN(num_lab_procedures) as minimum, ROUND(AVG(num_lab_procedures),0) as average, 
      MAX(num_lab_procedures) as maximum
FROM diabetic_data$

--divided the number of procedures into 3 different categories

SELECT ROUND(AVG(time_in_hospital), 0) AS days_stay, 
       CASE WHEN num_lab_procedures >= 0 AND num_lab_procedures < 25 THEN 'few'
            WHEN num_lab_procedures >= 25 AND num_lab_procedures < 55 THEN 'average'
            WHEN num_lab_procedures >= 55 THEN 'many' END AS procedure_frequency
FROM diabetic_data$
GROUP BY procedure_frequency
ORDER BY days_stay;

--TASK5-got an email from a co-worker in research. They want to do a medical test with anyone who is African American or had an “Up” for metformin. They need a list of patients' ids as fast as possible.
SELECT patient_nbr FROM diabetic_data$ WHERE race = 'AfricanAmerican'
 AND metformin = 'Up'
 ----TOTAL NUMBER OF PATIENTS----
WITH total_patients AS (
 SELECT patient_nbr FROM diabetic_data$ WHERE race = 'AfricanAmerican'
 AND metformin = 'Up'
)
SELECT COUNT(patient_nbr)
FROM total_patients

--Hospital Administrator wants to highlight some of the biggest success stories of the hospital. They are looking for opportunities when patients came into the hospital with an emergency (admission_type_id of 1) but stayed less than the average time in the hospital.

WITH average_time_hospital AS(
 SELECT AVG(time_in_hospital) as average
 FROM diabetic_data$
)
SELECT COUNT(*) as successful_case
FROM diabetic_data$
WHERE admission_type_id = 1
AND time_in_hospital < (SELECT* FROM average_time_hospital);

----output-- succesful case = 33684----

-----TOTAL CASES---
SELECT DISTINCT COUNT(*) as total_patients
FROM diabetic_data$;
--OUTPUT------------ 101766

--TASK 7: Provide a written summary of the TOP 50 medication patients.

SELECT TOP 50
CONCAT ('Patient ',patient_nbr,' had ',sum(num_medications),' medication and ',SUM(num_lab_procedures),' lab_procedures.')AS
SUMMARY
FROM diabetic_data$
group by patient_nbr
order by
SUM(num_medications) DESC,
SUM(num_lab_procedures) DESC
