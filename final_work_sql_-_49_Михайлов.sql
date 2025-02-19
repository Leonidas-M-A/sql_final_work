---1 задание----

select  model, count(seat_no) as number_of_seats
from seats s 
join aircrafts a on a.aircraft_code =s.aircraft_code 
group by model
having count(seat_no)<50

---2 задание---

select date_trunc('month', book_date)::date as book_date_by_month, sum(total_amount) as sum_total_amount,
		round((sum(total_amount) - lag(sum(total_amount), 1, null)over()) /
		lag(sum(total_amount), 1, null)over() * 100, 2) as change_procent
from bookings b
group by date_trunc('month', book_date)::date
order by date_trunc('month', book_date)::date

---3 задание---

select aircraft_code, model as aircraft_without_business
from aircrafts a2 
where array_position((select array_agg(distinct a.aircraft_code)as bus_on
						from aircrafts a 
						join seats s on a.aircraft_code = s.aircraft_code
						group by fare_conditions
						having fare_conditions='Business'),
	a2.aircraft_code) is null

--4 задание
	
select departure_airport, actual_departure,
		sum(seats_at_aircraft)over(partition by departure_airport, actual_departure order by flight_id) as empty_seat_sum_at_day
from (select distinct departure_airport, actual_departure, flight_id, count(seat_no) as seats_at_aircraft
		from (select departure_airport, f.flight_id,aircraft_code, actual_departure::date,
				count(f.flight_id)over(partition by departure_airport, actual_departure::date order by actual_departure::date) as flights_empty_count
				from flights f 
				left join ticket_flights tf on tf.flight_id = f.flight_id  
				group by departure_airport, f.flight_id,aircraft_code, actual_departure::date
				having count(tf.ticket_no) = 0 and actual_departure is not null 
				order by departure_airport) as fe
		left join aircrafts a on a.aircraft_code = fe.aircraft_code
		left join seats s on s.aircraft_code = fe.aircraft_code
		where flights_empty_count > 1
		group by departure_airport, actual_departure, flight_id
		order by departure_airport, actual_departure) as ss2		
		
		
	
--5 задание---

select distinct a.airport_name as departure_airport_name, a2.airport_name as arrival_airport_name,
		round(count(arrival_airport)over(partition by departure_airport, arrival_airport)::numeric/
		count(flight_id)over()::numeric * 100, 2) as percent_from_all
from flights f 
join airports a on a.airport_code = f.departure_airport
join airports a2 on a2.airport_code = f.arrival_airport
order by a.airport_name 

--6 задание---

select operator_code, count(passenger_id) as sum_passengers
from (select passenger_id, right(left(contact_data->>'phone', 5), 3) as operator_code
	 	from tickets t) as op
group by operator_code

--7 задание---

select level_amount, count(level_amount) as count_routes
from (select departure_airport, arrival_airport, sum(amount), 
				case 
					when sum(amount) < 50000000 then 'Low'
					when sum(amount) >= 150000000 then 'High'
					else 'Medium' 
				end as level_amount
		from ticket_flights tf 
		join flights f on f.flight_id = tf.flight_id 
		group by departure_airport, arrival_airport
		order by departure_airport) as s
group by level_amount

--8 задание---

select percentile_cont(0.5) within group (order by amount_book) as mediana_amount_booking,
		percentile_cont(0.5) within group (order by amount_one_ticket) as mediana_amount_tickets,
		round((percentile_cont(0.5) within group (order by amount_book) /
		percentile_cont(0.5) within group (order by amount_one_ticket))::numeric, 2) as attitude
from(select b.book_ref, sum(distinct total_amount) as amount_book, sum(distinct total_amount) / 
			count(t.ticket_no) as amount_one_ticket
	from bookings b
	join tickets t on b.book_ref = t.book_ref 
	group by b.book_ref
	order by b.book_ref) as b2  

--9 задание---
  
with koor_airport as (
	select airport_code, ll_to_earth(latitude,longitude) as koor
	from airports a
	)
select departure_airport, arrival_airport, amount_min / (earth_distance(ka.koor, ka2.koor)/1000) as amount_1km
from (select distinct departure_airport, arrival_airport, 
			min(amount)over(partition by departure_airport, arrival_airport) as amount_min
		from flights f 
		join ticket_flights tf on tf.flight_id = f.flight_id 
		order by departure_airport) as r
join koor_airport ka on ka.airport_code = r.departure_airport 
join koor_airport ka2 on ka2.airport_code = r.arrival_airport
order by amount_min / (earth_distance(ka.koor, ka2.koor)/1000)
limit 1


              
         
              


































