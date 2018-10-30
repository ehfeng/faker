create extension faker;
select random_uniform(1, 5);
select random_uniform(1.0::real, 2.0::real);
select random_uniform('2018-10-29'::timestamp, '2018-10-30'::timestamp);