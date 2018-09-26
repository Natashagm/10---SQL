use sakila;

#1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat( first_name, ' ', last_name)) as "Actor Name" from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name='Joe';

#2b. Find all actors whose last name contain the letters GEN:
select * from actor where upper(last_name) like '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where upper(last_name) like '%LI%' order by last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ( 'Afghanistan', 'Bangladesh', 'China');

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor add middle_name varchar(45) AFTER first_name;

#3b. You realize that some of these actors have tremendously long last names. 
# Change the data type of the middle_name column to blobs.
alter table actor modify middle_name blob;

#3c. Now delete the middle_name column.
alter table actor drop column middle_name;

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) number_of_actors from actor group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) number_of_actors from actor group by last_name
having count(*)>1;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor
set first_name='HARPO'
where last_name='WILLIAMS' and first_name='GROUCHO';

/* 
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
(Hint: update the record using a unique identifier.)
*/
update actor
set first_name= 
case when first_name='HARPO' then 'GROUCHO' 
     when first_name='GROUCHO' then 'MUCHO GROUCHO'
     else first_name
end
where last_name='WILLIAMS'; 

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address; 
/*
CREATE TABLE address (
   address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   address varchar(50) NOT NULL,
   address2 varchar(50) DEFAULT NULL,
   district varchar(20) NOT NULL,
   city_id smallint(5) unsigned NOT NULL,
   postal_code varchar(10) DEFAULT NULL,
   phone varchar(20) NOT NULL,
   location geometry NOT NULL,
   last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (address_id),
   KEY idx_fk_city_id (city_id),
   SPATIAL KEY idx_location (location),
   CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE
 ) ; 
*/

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name,concat(address,coalesce(address2,''),', ',district,' distinct, ',city, ' city',
	case when  trim(postal_code)  ='' then '' else concat(', ',postal_code)
	end ) as address  
from staff join address using (address_id)
join city using (city_id);

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select sum(amount) august_amount, staff_id 
from payment join staff using (staff_id) 
where payment_date between '2005-08-01' and '2005-09-01'
group by staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title as film, count(*) nbr_of_actors from film_actor join film using (film_id)
group by film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) nbr_of_copies 
  from inventory join film using (film_id)
where title="Hunchback Impossible";


#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
#![Total amount paid](Images/total_payment.png)
select last_name as customer_last_name
	, first_name as customer_first_name
    , sum(amount) as amount 
from payment join customer using (customer_id)
group by customer_id
order by 1;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title 
from film join language using (language_id) 
where language.name='English'
and (substr(title,1,1) in ('K','Q'));

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select concat(first_name,' ', last_name ) as actor
from actor join film_actor using (actor_id)
join film  using (film_id)
where title='Alone Trip';

#7c. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers.
# Use joins to retrieve this information.
select first_name, last_name, email 
from customer join address using (address_id)
  join city using (city_id)
  join country using (country_id)
where country='Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as family films.
select * from film;

#7e. Display the most frequently rented movies in descending order.
select count(*) nbr_of_rentals, title 
from rental join inventory using (inventory_id)
  join film using (film_id)
group by film_id 
order by count(*) desc; 

#7f. Write a query to display how much business, in dollars, each store brought in.
select sum(amount), store_id 
from payment join staff using (staff_id)
 join store using (store_id)
group by store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store join address using(address_id)
join city using (city_id)
join country using (country_id);

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select n from (
  select sum(amount) s, name n  
  from category join film_category using (category_id)
    join inventory using (film_id)
    join rental using (inventory_id )
    join payment using ( rental_id)
  group by category_id
) a
order by s desc
limit 5; 

#8a. In your new role as an executive, you would like to have an easy way of viewing the 
#Top five genres by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as
 select sum(amount) s, name n  
  from category join film_category using (category_id)
    join inventory using (film_id)
    join rental using (inventory_id )
    join payment using ( rental_id)
  group by category_id
  order by s desc
limit 5; 

#8b. How would you display the view that you created in 8a?
select * from top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;
