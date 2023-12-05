-- CS4400: Introduction to Database Systems (Fall 2022)
-- Project Phase III: Stored Procedures SHELL [v2] Wednesday, November 30, 2022
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use restaurant_supply_express;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username.  Also, the new owner is not allowed to be an employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
    if (ip_username is null)
    or (ip_first_name is null)
    or (ip_last_name is null)
    or (ip_address is null)
    or (ip_birthdate is null)
    or exists (select * from users where users.username = ip_username)
        -- ensure new owner has a unique username
    then
        leave sp_main;
    else
        insert into users(username, first_name, last_name, address, birthdate)
        values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
        insert into restaurant_owners(username)
        values (ip_username);
    end if;

end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated pilot or
worker roles.  A new employee must have a unique username unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name 
varchar(100),
in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate 
date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
   if (ip_username is null)
    or (ip_first_name is null)
    or (ip_last_name is null)
    or (ip_address is null)
    or (ip_birthdate is null)
    or (ip_taxID is null)
    or (ip_hired is null)
    or (ip_employee_experience is null)
    or (ip_salary is null)
    or exists (select * from users where users.username = ip_username)
    or exists (select * from employees where employees.taxID = ip_taxID) 
    then 
    leave sp_main;
    else 
    insert into users(username, first_name, last_name, address, birthdate)
    values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    insert into employees(username, taxID, hired, experience, salary)
    values (ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
    end if; 

end //
delimiter ;

-- [3] add_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the pilot role to an existing employee.  The
employee/new pilot must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_pilot_role;
delimiter //
create procedure add_pilot_role (in ip_username varchar(40), in ip_licenseID varchar(40),
    in ip_pilot_experience integer)
sp_main: begin
if (ip_username is null)
    or (ip_licenseID is null)
    or (ip_pilot_experience is null)
    or not exists (select * from employees where employees.username = ip_username)
     -- ensure new employee exists
    or exists (select * from pilots where pilots.licenseID = ip_licenseID)
     -- ensure new pilot has a unique license identifier
    then
        leave sp_main;
    else
        insert into pilots(username, licenseID, experience)
        values (ip_username, ip_licenseID, ip_pilot_experience);
    end if;
end //
delimiter ;
-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
	if (ip_username = null)
    or not exists (select * from employees where employees.username = ip_username)
    then
		leave sp_main;
	else
		insert into workers(username)
        values (ip_username);
	end if;
    -- ensure new employee exists
end //
delimiter ;

-- [5] add_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ingredient.  A new ingredient must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ingredient;
delimiter //
create procedure add_ingredient (in ip_barcode varchar(40), in ip_iname varchar(100),
    in ip_weight integer)
sp_main: begin
    if (ip_barcode is null)
    or (ip_iname is null)
    or (ip_weight is null)
    or exists (select * from ingredients where ingredients.barcode = ip_barcode)
        -- ensure new ingredient doesn't already exist
    then
        leave sp_main;
    else
        insert into ingredients(barcode, iname, weight)
        values (ip_barcode, ip_iname, ip_weight) ;
    end if;
end //
delimiter ;

-- [6] add_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new drone.  A new drone must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be flown
by a valid pilot initially (i.e., pilot works for the same service), but the pilot
can switch the drone to working as part of a swarm later. And the drone's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_drone;
delimiter //
create procedure add_drone (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_flown_by varchar(40))
sp_main: begin
	if (ip_id = null)
    or (ip_tag = null)
    or (ip_fuel = null)
    or (ip_fuel < 0)
    or (ip_capacity = null)
    or (ip_capacity < 0)
    or (ip_sales = null)
    or (ip_sales < 0)
    or (ip_flown_by = null)
    or exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag)
	-- ensure new drone doesn't already exist
    or not exists (select * from delivery_services where delivery_services.id = ip_id)
    -- ensure that the delivery service exists
    or not exists (select * from work_for where work_for.username = ip_flown_by and work_for.id = ip_id)
    -- ensure that a valid pilot will control the drone
    then
		leave sp_main;
	else
		insert into drones(id, tag, fuel, capacity, sales, flown_by, swarm_id, swarm_tag, hover)
        values (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_flown_by, null, null, (select home_base from delivery_services where delivery_services.id = ip_id));
    end if;
end //
delimiter ;

-- [7] add_restaurant()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new restaurant.  A new restaurant must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_restaurant;
delimiter //
create procedure add_restaurant (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	if (ip_long_name is null)
    or (ip_location is null)
    or (ip_rating not between 1 and 5)
    or exists (select * from restaurants where restaurants.long_name = ip_long_name)
    then
        leave sp_main;
    else
        insert into restaurants(long_name, rating, spent, location)
        values (ip_long_name, ip_rating, ip_spent, ip_location);
    end if;
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	if (ip_id = null)
    or (ip_long_name = null)
    or (ip_home_base = null)
    or (ip_manager = null)
    or exists (select * from delivery_services where delivery_services.id = ip_id and delivery_services.manager = ip_manager)
	-- ensure new delivery service doesn't already exist
    or not exists (select * from locations where locations.label = ip_home_base)
    -- ensure that the home base location is valid
    or not exists (select * from employees where employees.username = ip_manager)
    or not exists (select * from workers where workers.username = ip_manager)
    -- ensure that the manager is valid
    then
		leave sp_main;
	else
		insert into delivery_services(id, long_name, home_base, manager)
        values (ip_id, ip_long_name, ip_home_base, ip_manager);
    end if;
end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid drone
destination.  A new location must have a unique combination of coordinates.  We
could allow for "aliased locations", but this might cause more confusion that
it's worth for our relatively simple system. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
    in ip_y_coord integer, in ip_space integer)
sp_main: begin
    if (ip_label is null)
    or (ip_x_coord is null)
    or (ip_y_coord is null)
    or (ip_space is null)
    or exists (select * from locations where locations.label = ip_label)
          -- ensure new location doesn't already exist
    or exists (select * from locations where locations.x_coord = ip_x_coord and locations.y_coord = ip_y_coord)
        -- ensure that the coordinate combination is distinct
    then
        leave sp_main;
    else
        insert into locations(label, x_coord, y_coord, space)
        values (ip_label, ip_x_coord, ip_y_coord, ip_space) ;
    end if;
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a restaurant owner to provide funds
to a restaurant. If a different owner is already providing funds, then the current
owner is replaced with the new owner.  The owner and restaurant must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_long_name varchar(40))
sp_main: begin
    if (ip_owner = null)
    or (ip_long_name = null)
    or not exists (select * from restaurant_owners where restaurant_owners.username = ip_owner)
    or not exists (select * from restaurants where restaurants.long_name = ip_long_name)
    -- ensure the owner and restaurant are valid
    then
        leave sp_main;
    else
        update restaurants
        set funded_by = ip_owner
        where restaurants.long_name = ip_long_name;
    end if;
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires an employee to work for a delivery service.
Employees can be combinations of workers and pilots. If an employee is actively
controlling drones or serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
    if (ip_username = null)
    or (ip_id = null)
    or not exists (select * from employees where employees.username = ip_username)
    or not exists (select * from delivery_services where delivery_services.id = ip_id)
        -- ensure that the employee and delivery service are valid
    or exists (select * from work_for where work_for.username = ip_username and work_for.id = ip_id)
        -- ensure that the employee hasn't already been hired
    or exists (select * from delivery_services where delivery_services.manager = ip_username)
        -- ensure that the employee isn't a manager for another service
    or exists (select * from drones where drones.flown_by = ip_username)
        -- ensure that the employee isn't actively controlling drones for another service
    then
        leave sp_main;
    else
        insert into work_for(username, id)
        values (ip_username, ip_id);
    end if;
end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires an employee who is currently working for a delivery
service.  The only restrictions are that the employee must not be: [1] actively
controlling one or more drones; or, [2] serving as a manager for the service.
Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	if (ip_username = null)
    or (ip_id = null)
    or not exists (select * from work_for where work_for.username = ip_username and work_for.id = ip_id)
	-- ensure that the employee is currently working for the service
    or exists (select * from delivery_services where delivery_services.manager = ip_username)
    -- ensure that the employee isn't an active manager
    or exists (select * from drones where drones.flown_by = ip_username)
	-- ensure that the employee isn't controlling any drones
    then
		leave sp_main;
	else
		delete from work_for
        where work_for.username = ip_username and work_for.id = ip_id;
	end if;
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints an employee who is currently hired by a delivery
service as the new manager for that service.  The only restrictions are that: [1]
the employee must not be working for any other delivery service; and, [2] the
employee can't be flying drones at the time.  Otherwise, the appointment to manager
is permitted.  The current manager is simply replaced.  And the employee must be
granted the worker role if they don't have it already. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
if (ip_username = null)
    or (ip_id = null)
    or not exists (select * from work_for where work_for.username = ip_username and work_for.id = ip_id)
        -- ensure that the employee is currently working for the service
    or exists (select * from drones where drones.flown_by = ip_username)
        -- ensure that the employee is not flying any drones
    or exists (select id from work_for where work_for.username = ip_username and id not in (ip_id))
        -- ensure that the employee isn't working for any other services
    then
        leave sp_main;
    else
        update delivery_services
        set manager = ip_username
        where id = ip_id;
        if not exists (select * from workers where workers.username = ip_username)
        then
        call add_worker_role(ip_username);
        end if;
        -- add the worker role if necessary
    end if;
end //
delimiter ;

-- [14] takeover_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid pilot to take control of a lead drone owned
by the same delivery service, whether it's a "lone drone" or the leader of a swarm.
The current controller of the drone is simply relieved of those duties. And this
should only be executed if a "leader drone" is selected. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_drone;
delimiter //
create procedure takeover_drone (in ip_username varchar(40), in ip_id varchar(40),
    in ip_tag integer)
sp_main: begin
    if (ip_username = null)
    or (ip_id = null)
    or (ip_tag = null)
    or not exists (select * from work_for where work_for.username = ip_username and work_for.id = ip_id)
    -- ensure that the employee is currently working for the service
    or not exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag and (drones.flown_by is not null))
    -- ensure that the selected drone is owned by the same service and is a leader and not follower
    or exists (select * from delivery_services where delivery_services.manager = ip_username)
    -- ensure that the employee isn't a manager
    or not exists (select * from pilots where pilots.username = ip_username)
    -- ensure that the employee is a valid pilot
    then
        leave sp_main;
    else
        update drones
        set drones.flown_by = ip_username
        where drones.id = ip_id and drones.tag = ip_tag;
    end if;
end //
delimiter ;


-- [15] join_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently being directly controlled
by a pilot and has it join a swarm (i.e., group of drones) led by a different
directly controlled drone. A drone that is joining a swarm connot be leading a
different swarm at this time.  Also, the drones must be at the same location, but
they can be controlled by different pilots. */
-- -----------------------------------------------------------------------------
drop procedure if exists join_swarm;
delimiter //
create procedure join_swarm (in ip_id varchar(40), in ip_tag integer,
    in ip_swarm_leader_tag integer)
sp_main: begin
    if (ip_id = null)
    or (ip_tag = null)
    or (ip_swarm_leader_tag = null)
    or (ip_tag = ip_swarm_leader_tag)
    -- ensure that the swarm leader is a different drone
    or not exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag)
    -- ensure that the drone joining the swarm is valid and owned by the service
    or exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag and drones.flown_by = null)
    -- ensure that the swarm leader drone is directly controlled
    or exists (select * from drones where drones.swarm_id = ip_id and drones.swarm_tag = ip_tag)
    -- ensure that the drone joining the swarm is not already leading a swarm
    or isnull((select hover from drones where id in (ip_id) and tag in (ip_tag)) = (select hover from drones where id in (ip_id) and tag in (ip_swarm_leader_tag)))
    or not ((select hover from drones where id in (ip_id) and tag in (ip_tag)) = (select hover from drones where id in (ip_id) and tag in (ip_swarm_leader_tag)))
    -- ensure that the drones are at the same location
    then
        leave sp_main;
    else
        update drones
        set drones.flown_by = null, drones.swarm_id = ip_id, drones.swarm_tag = ip_swarm_leader_tag
        where drones.id = ip_id and drones.tag = ip_tag;
    end if;
end //
delimiter ;


-- [16] leave_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently in a swarm and returns
it to being directly controlled by the same pilot who's controlling the swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists leave_swarm;
delimiter //
create procedure leave_swarm (in ip_id varchar(40), in ip_swarm_tag integer)
sp_main: begin
  if (ip_id is null)
    or (ip_swarm_tag is null) -- ip_swarm_tag is actually the ip_tag of the drone that is leaving
    or ((select swarm_id from drones where drones.id = ip_id and drones.tag = ip_swarm_tag) is null)
    -- ensure that the selected drone is owned by the service and flying in a swarm
    then 
      leave sp_main;
  else
  
    drop table if exists flown_by;
    create temporary table flown_by select flown_by from drones where drones.id = ip_id and drones.tag = (select swarm_tag from drones where drones.id = ip_id and drones.tag = ip_swarm_tag); 
    update drones
    set drones.flown_by = (select * from flown_by), drones.swarm_id = null, drones.swarm_tag = null
    where drones.id = ip_id and drones.tag = ip_swarm_tag;
  end if;
end //
delimiter ;

-- [17] load_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific ingredient to a drone's payload so that we can sell them for some
specific price to other restaurants.  The drone can only be loaded if it's located
at its delivery service's home base, and the drone must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the ingredient already loaded onto the drone as applicable.  And if the ingredient
already exists on the drone, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_drone;
delimiter //
create procedure load_drone (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
    in ip_more_packages integer, in ip_price integer)
sp_main: begin
    if (ip_id = null)
    or (ip_tag = null)
    or (ip_barcode = null)
    or (ip_more_packages = null)
    or (ip_more_packages <= 0)
        -- ensure that the quantity of new packages is greater than zero
    or (ip_price = null)
    or not exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag and drones.hover = (select home_base from delivery_services where id in (ip_id)))
        -- ensure that the drone being loaded is owned by the service
        -- ensure that the drone is located at the service home base
    or not exists (select * from ingredients where ingredients.barcode = ip_barcode)
        -- ensure that the ingredient is valid
    or ((ip_more_packages +(select ifnull(sum(payload.quantity), 0) from payload where payload.id = ip_id and payload.tag = ip_tag)) > (select drones.capacity from drones where drones.id = ip_id and drones.tag = ip_tag))
        -- ensure that the drone has sufficient capacity to carry the new packages
    then
        leave sp_main;
    else
        if exists (select * from payload where payload.id = ip_id and payload.tag = ip_tag and payload.barcode = ip_barcode)
        then
            update payload
            set quantity = (ip_more_packages +(select sum(payload.quantity) from payload where payload.id = ip_id and payload.tag = ip_tag))
            where payload.id = ip_id and payload.tag = ip_tag and payload.barcode = ip_barcode;
        else
            insert into payload(id, tag, barcode, quantity, price)
            values (ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price);
        end if;
    end if;
    -- add more of the ingredient to the drone
end //
delimiter ;

-- [18] refuel_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a drone. The drone can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_drone;
delimiter //
create procedure refuel_drone (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
    if (ip_id = null)
    or (ip_tag = null)
    or (ip_more_fuel = null)
    or not exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag and drones.hover = (select home_base from delivery_services where id in (ip_id)))
    -- ensure that the drone being switched is valid and owned by the service
    -- ensure that the drone is located at the service home base
    then
        leave sp_main;
    else
		drop temporary table if exists current_fuel;
		create temporary table current_fuel (fuel int);
        insert into current_fuel(fuel) values((select fuel from drones where drones.id = ip_id and drones.tag = ip_tag));
        
        update drones
        set fuel = (ip_more_fuel + (select * from current_fuel))
        where drones.id = ip_id and drones.tag = ip_tag;
    end if;
end //
delimiter ;


-- [19] fly_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single or swarm of drones to a new
location (i.e., destination). The main constraints on the drone(s) being able to
move to a new location are fuel and space.  A drone can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a drone can only move to a destination if there's enough
space remaining at the destination.  For swarms, the flight directions will always
be given to the lead drone, but the swarm must always stay together. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
    returns integer reads sql data
begin
    if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
        from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
    end if;
end //
delimiter ;

drop procedure if exists fly_drone;
delimiter //
create procedure fly_drone (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
    if (ip_id is null)
    or (ip_tag is null)
    or (ip_destination is null)
    # or not exists (select * from drones where drones.
    -- ensure that the lead drone being flown is directly controlled and owned by the service
    or not exists (select * from locations where locations.label = ip_destination)
    -- ensure that the destination is a valid location
    or (ip_destination in (select hover from drones where drones.id = ip_id and drones.tag = ip_tag))
    -- ensure that the drone isn't already at the location
    or  ((fuel_required((select hover from drones where drones.id = ip_id and drones.tag = ip_tag), ip_destination))  
     + (fuel_required(ip_destination, (select home_base from delivery_services where delivery_services.id = ip_id))))
    > (select fuel from drones where drones.id = ip_id and drones.tag = ip_tag)
    -- ensure that the drone/swarm has enough fuel to reach the destination and (then) home base
    or (select space from locations where label = ip_destination) < (select ifnull(sum(drones.tag) + 1 , 1)
        from drones where drones.swarm_id = ip_id and drones.swarm_tag = ip_tag)
    -- ensure that the drone/swarm has enough space at the destination for the flight
  then
    leave sp_main;
  else
    drop temporary table if exists current_fuel;
    drop temporary table if exists subtract;
    create temporary table current_fuel (cfuel int, tag varchar(40));
    insert into current_fuel(cfuel, tag) values((select fuel from drones where (drones.id = ip_id and drones.tag = ip_tag)), ip_tag);
    insert into current_fuel(cfuel, tag) values((select fuel from drones where (drones.swarm_tag = ip_tag and drones.swarm_id = ip_id)), (select tag from drones where (drones.swarm_tag = ip_tag and drones.swarm_id = ip_id)));
    create temporary table subtract (sfuel int, tag varchar(40));
    insert into subtract(sfuel, tag) values((fuel_required((select hover from drones where (drones.id = ip_id and drones.tag = ip_tag)), ip_destination)), ip_tag);
    insert into subtract(sfuel, tag) values((fuel_required((select hover from drones where (drones.swarm_tag = ip_tag and drones.swarm_id = ip_id)), ip_destination)),
											(select tag from drones where (drones.swarm_tag = ip_tag and drones.swarm_id = ip_id)));
    update drones
    set drones.hover = ip_destination,
    drones.fuel = (select cfuel from current_fuel where current_fuel.tag = ip_tag) - (select sfuel from subtract where subtract.tag = ip_tag)
    where drones.id = ip_id and drones.tag = ip_tag;
    
    update drones
    set drones.hover = ip_destination,
    drones.fuel = (select cfuel from current_fuel where current_fuel.tag = drones.tag) - (select sfuel from subtract where subtract.tag = drones.tag)
    where drones.swarm_id = ip_id and drones.swarm_tag = ip_tag;
    
    drop temporary table if exists current_fuel;
    drop temporary table if exists subtract;
  end if;
end //
delimiter ;


-- [20] purchase_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a restaurant to purchase ingredients from a drone
at its current location.  The drone must have the desired quantity of the ingredient
being purchased.  And the restaurant must have enough money to purchase the
ingredients.  If the transaction is otherwise valid, then the drone and restaurant
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ingredient;
delimiter //
create procedure purchase_ingredient (in ip_long_name varchar(40), in ip_id varchar(40),
    in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
  if (ip_long_name is null)
    or (ip_id is null)
    or (ip_tag is null)
    or (ip_barcode is null)
    or (ip_quantity is null)
    or not exists (select * from restaurants where restaurants.long_name = ip_long_name)
    -- ensure that the restaurant is valid
    
    or not exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag)
    or not ((select location from restaurants where restaurants.long_name = ip_long_name) 
        in (select hover from drones where drones.id = ip_id and drones.tag = ip_tag))
    -- ensure that the drone is valid and exists at the restaurant's location
    
    or not ((select quantity from payload where payload.id = ip_id and payload.tag = ip_tag and payload.barcode = ip_barcode) >= ip_quantity)
    -- ensure that the drone has enough of the requested ingredient
    
    then 
      leave sp_main;
    else
    drop table if exists sale_price;
    create temporary table sale_price select price
    from payload where payload.id = ip_id and payload.tag = ip_tag and payload.barcode = ip_barcode; -- price of sale
    
    drop table if exists payload_quantity;
    create temporary table payload_quantity select payload.quantity
    from payload where payload.id = ip_id and payload.tag = ip_tag and payload.barcode = ip_barcode; -- payload.quantity
    
    update payload
    set payload.quantity = (select * from payload_quantity) - ip_quantity
    where payload.id = ip_id and payload.tag = ip_tag and payload.barcode = ip_barcode;
    -- update the drone's payload
    
    drop table if exists restaurants_spent;
    create temporary table restaurants_spent select restaurants.spent 
    from restaurants where restaurants.long_name = ip_long_name; -- 
    
    update restaurants 
    set restaurants.spent = (select * from restaurants_spent) + ((select * from sale_price) * ip_quantity)
    where restaurants.long_name = ip_long_name;
    
    drop table if exists drones_sales;
    create temporary table drones_sales select drones.sales
    from drones where drones.id = ip_id and drones.tag = ip_tag;
    
    update drones 
    set drones.sales = (select * from drones_sales) + ((select * from sale_price) * ip_quantity)
    where drones.id = ip_id and drones.tag = ip_tag;
    -- update the monies spent and gained for the drone and restaurant
    
    delete from payload 
    where payload.quantity < 1;
    -- ensure all quantities in the payload table are greater than zero
    end if;
end //
delimiter ;
-- [21] remove_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure removes an ingredient from the system.  The removal can
occur if, and only if, the ingredient is not being carried by any drones. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_ingredient;
delimiter //
create procedure remove_ingredient (in ip_barcode varchar(40))
sp_main: begin
    if (ip_barcode = null)
    or not exists (select * from ingredients where ingredients.barcode = ip_barcode)
        -- ensure that the ingredient exists
    or exists (select * from payload where payload.barcode = ip_barcode)
        -- ensure that the ingredient is not being carried by any drones
    then
        leave sp_main;
    else
    delete from ingredients
    where ingredients.barcode = ip_barcode;
    end if;
end //
delimiter ;

-- [22] remove_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a drone from the system.  The removal can
occur if, and only if, the drone is not carrying any ingredients, and if it is
not leading a swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_drone;
delimiter //
create procedure remove_drone (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
    if (ip_id = null)
    or (ip_tag = null)
    or not exists (select * from drones where drones.id = ip_id and drones.tag = ip_tag)
    -- ensure that the drone exists
    or exists (select * from payload where payload.id = ip_id and payload.tag = ip_tag)
    -- ensure that the drone is not carrying any ingredients
    or exists (select * from drones where drones.swarm_id = ip_id and drones.swarm_tag = ip_tag)
    -- ensure that the drone is not leading a swarm
    then
        leave sp_main;
    else
        delete from drones
        where drones.id = ip_id and drones.tag = ip_tag;
    end if;
end //
delimiter ;

-- [23] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a pilot from the system.  The removal can
occur if, and only if, the pilot is not controlling any drones.  Also, if the
pilot also has a worker role, then the worker information must be maintained;
otherwise, the pilot's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_username varchar(40))
sp_main: begin
    if (ip_username = null)
    or exists (select * from drones where drones.flown_by = ip_username)
    then
        leave sp_main;
    else
        delete from pilots where pilots.username = ip_username;
        if not exists (select * from workers where workers.username = ip_username)
        then
            delete from users where users.username = ip_username;
        end if;
    end if;
    -- ensure that the pilot exists
    -- ensure that the pilot is not controlling any drones
    -- remove all remaining information unless the pilot is also a worker
end //
delimiter ;

-- [24] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
restaurants for which they provide funds and the number of different places where
those restaurants are located.  It also includes the highest and lowest ratings
for each of those restaurants, as well as the total amount of debt based on the
monies spent purchasing ingredients by all of those restaurants. And if an owner
doesn't fund any restaurants then display zeros for the highs, lows and debt. */
-- -----------------------------------------------------------------------------
create or replace view display_owner_view as
select restaurant_owners.*, users.first_name, users.last_name, users.address,
    (select count(*) from restaurants where restaurants.funded_by = restaurant_owners.username) as num_restaurants,
    (select count(distinct restaurants.location) from restaurants where restaurants.funded_by = restaurant_owners.username) as num_places,
    (select ifnull(max(restaurants.rating), 0) from restaurants where restaurants.funded_by = restaurant_owners.username) as highs,
    (select ifnull(min(restaurants.rating), 0) from restaurants where restaurants.funded_by = restaurant_owners.username) as lows,
    (select ifnull(sum(restaurants.spent), 0) from restaurants where restaurants.funded_by = restaurant_owners.username) as debt
from restaurant_owners
inner join users on restaurant_owners.username = users.username;

-- [25] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, hiring date and
experience level, along with the license identifer and piloting experience (if
applicable), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
select distinct employees.username, employees.taxID, employees.salary, employees.hired, employees.experience as employee_experience, ifnull(pilots.licenseID, 'n/a') as licenseID,
ifnull(pilots.experience, 'n/a') as piloting_experience,
case when delivery_services.manager = employees.username then 'yes' else 'no' end as manager_status
from employees 
left join pilots on employees.username = pilots.username
left join delivery_services on delivery_services.manager = employees.username;


-- [26] display_pilot_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a pilot.
For each pilot, it includes the username, licenseID and piloting experience, along
with the number of drones that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_pilot_view as
select pilots.username, pilots.licenseID, pilots.experience,
(select count(*) from drones where drones.flown_by = pilots.username) +  
        (select count(*) from drones where drones.swarm_id in (select drones.id from drones where drones.flown_by = pilots.username)
            and drones.swarm_tag in (select drones.tag from drones where drones.flown_by = pilots.username)) as num_drones,
(select count(distinct drones.hover) from drones where drones.flown_by = pilots.username) as num_locations
from pilots;


-- [27] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
number of restaurants, delivery services and drones at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_location_view as
select locations.label, locations.x_coord, locations.y_coord,
(select count(*) from restaurants where restaurants.location = locations.label) as num_restaurants,
(select count(*) from delivery_services where delivery_services.home_base = locations.label) as num_delivery_services,
(select count(*) from drones where drones.hover = locations.label) as num_drones
from locations;

-- [28] display_ingredient_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the ingredients.
For each ingredient that is being carried by at least one drone, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the ingredient is being
sold at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_ingredient_view as
select ingredients.iname,
drones.hover as location,
payload.quantity as amount_available,
(select min(payload.price) from payload, drones where payload.barcode = ingredients.barcode and drones.id = payload.id and drones.tag = payload.tag and drones.hover = location) as low_price,
(select max(payload.price) from payload, drones where payload.barcode = ingredients.barcode and drones.id = payload.id and drones.tag = payload.tag and drones.hover = location) as high_price
from ingredients
inner join payload on payload.barcode = ingredients.barcode
inner join drones on drones.tag = payload.tag and drones.id = payload.id
order by ingredients.iname, location;

-- [29] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the drones.  It must also include the number
of unique ingredients along with the total cost and weight of those ingredients being
carried by the drones. */
-- -----------------------------------------------------------------------------
create or replace view display_service_view as
select distinct delivery_services.*,
(select sum(drones.sales) from drones where drones.id = delivery_services.id) as revenue,
(select count(distinct(payload.barcode)) from payload where payload.id = delivery_services.id) as ingredients_carried,
(select sum(payload.price * payload.quantity) from payload where payload.id = delivery_services.id) as cost_carried,
(select sum(payload.quantity * ingredients.weight) from payload, ingredients where payload.id = delivery_services.id and ingredients.barcode = payload.barcode) as weight_carried
from delivery_services
inner join drones on delivery_services.id = drones.id;

