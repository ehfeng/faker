# Faker

Toying with ideas for generating fake data directly within SQL.

```PLpgSQL
-- Create and populate organizations
create table organizations(
  id serial primary key,
  created timestamp default now(),
  name text not null,
  domain text
);

insert into organizations(created, name, domain)
  with base as (
    select random_uniform((now() - '1 year'::interval)::timestamp, now()::timestamp) as created,
      fake_company_name() as name
    from generate_series(1, 100))
  select created, name, fake_domain(name) as domain from base
on conflict do nothing;

-- Create and populate users
create table users(
  id serial primary key,
  created timestamp default now(),
  name text not null,
  email text not null unique
);

insert into users(created, name, email)
  with base as (
    select
      random_uniform((now() - '1 year'::interval)::timestamp, now()::timestamp) as created,
      fake_name() as name
    from generate_series(1, 1000))
  select created, name, generate_email(name)
  from base
on conflict do nothing;

create table organization_members(
  user_id integer references users(id),
  organization_id integer references organizations(id),
  created timestamp,
  role text not null
);

-- Join them to organization_id
insert into organization_members(user_id, organization_id, created, role)
  with base as (select id, created from users),
  org_array as (select array_agg(id) as ids from organizations)
  select id as user_id,
    random_choice(org_array.ids::integer[]) as organization_id,
    created,
    random_choice('{"owner", "member", "member", "member"}'::text[]) as role
  from base
  cross join org_array
on conflict do nothing;
```

## Install

Clone repo and `make install`

Within database, `create extension faker`

## Credits

Thanks to [big elephants](http://big-elephants.com/2015-10/writing-postgres-extensions-part-i/) for a great tutorial.

Inspired by [Faker](https://github.com/joke2k/faker) and Python's [random module](https://docs.python.org/3/library/random.html).
