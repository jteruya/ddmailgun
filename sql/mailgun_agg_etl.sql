--============================================================================================================
-- Table: agg_status_per_domain 
-- Description: This is an aggregate table by recipient email domain for the different mailgun event counts. 
--============================================================================================================
drop table if exists mailgun.agg_status_per_domain;
create table mailgun.agg_status_per_domain as
select mailguncube.recipientemaildomain
     , count(case when accepted_flag = true then 1 else null end) as accepted
     , count(case when rejected_flag = true then 1 else null end) as rejected
     , count(case when delivered_flag = true then 1 else null end) as delivered
     , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed               
     , count(case when opened_flag = true then 1 else null end) as opened
     , count(case when clicked_flag = true then 1 else null end) as clicked
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed
     , count(case when complained_flag = true then 1 else null end) as complained
     , count(case when stored_flag = true then 1 else null end) as stored
from mailgun.mailguncube mailguncube
group by mailguncube.recipientemaildomain;


--============================================================================================================
-- Table: agg_status_per_event 
-- Description: This is an aggregate table by application id for the different mailgun event counts. 
--============================================================================================================
drop table if exists mailgun.agg_status_per_event;
create table mailgun.agg_status_per_event as
select mailguncube.applicationid
     , events.name
     , case
          when events.eventtype = '' or events.eventtype is null then 'No Event Type'
          else events.eventtype
       end as eventtype
     , events.startdate
     , events.enddate
     , count(case when accepted_flag = true then 1 else null end) as accepted
     , count(case when rejected_flag = true then 1 else null end) as rejected
     , count(case when delivered_flag = true then 1 else null end) as delivered
     , count(case when failed_flag = true and delivered_flag = false then 1 else null end) as failed               
     , count(case when opened_flag = true then 1 else null end) as opened
     , count(case when clicked_flag = true then 1 else null end) as clicked
     , count(case when unsubscribed_flag = true then 1 else null end) as unsubscribed
     , count(case when complained_flag = true then 1 else null end) as complained
     , count(case when stored_flag = true then 1 else null end) as stored
from mailgun.mailguncube mailguncube
left join authdb_applications events
on mailguncube.applicationid = events.applicationid::uuid
group by mailguncube.applicationid, events.name, events.eventtype, events.startdate, events.enddate;
