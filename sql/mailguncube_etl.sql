--============================================================================================================
-- Table: mailguncube_delta 
-- Description: This table pulls all records from mailgun_events that are greater than the largest value in
--		the field eventtimestamp_created in the table mailguncube.  This field holds the max value
--		of the table mailgun_events to determine which records are the delta records that require new
--		messageids to be inserted or older messageids to be updated.  
--============================================================================================================

create temporary table mailguncube_delta as
select a.messageid
     , a.applicationid
     , b.maxeventtimestamp
     , min(a.recipientemail) as recipientemail
     , min(a.senderemail) as senderemail
     , min(a.subject) as subject
     , min(case when a.eventstatus = 'accepted' then to_timestamp(a.eventtimestamp/1000) else null end) as first_accepted_timestamp
     , min(case when a.eventstatus = 'rejected' then to_timestamp(a.eventtimestamp/1000) else null end) as first_rejected_timestamp
     , min(case when a.eventstatus = 'delivered' then to_timestamp(a.eventtimestamp/1000) else null end) as first_delivered_timestamp
     , min(case when a.eventstatus = 'failed' then to_timestamp(a.eventtimestamp/1000) else null end) as first_failed_timestamp
     , min(case when a.eventstatus = 'opened' then to_timestamp(a.eventtimestamp/1000) else null end) as first_opened_timestamp
     , min(case when a.eventstatus = 'clicked' then to_timestamp(a.eventtimestamp/1000) else null end) as first_clicked_timestamp
     , min(case when a.eventstatus = 'unsubscribed' then to_timestamp(a.eventtimestamp/1000) else null end) as first_unsubscribed_timestamp
     , min(case when a.eventstatus = 'complained' then to_timestamp(a.eventtimestamp/1000) else null end) as first_complained_timestamp
     , min(case when a.eventstatus = 'stored' then to_timestamp(a.eventtimestamp/1000) else null end) as first_stored_timestamp
from (select * from public.mailgun_events where eventtimestamp > (select coalesce(max(eventtimestamp_created), 0) as maxeventtimestamp from public.mailguncube)) a
join (select max(eventtimestamp) as maxeventtimestamp from public.mailgun_events) b
on 1 = 1
group by a.messageid, a.applicationid, b.maxeventtimestamp;


--============================================================================================================
-- Table: mailguncube_delta_update 
-- Description: This table contains all records from mailguncube_delta that are udpate records. 
--============================================================================================================

create temporary table mailguncube_delta_update as
select exist.messageid
     , coalesce(exist.applicationid, delta.applicationid) as applicationid
     , coalesce(exist.recipientemail, delta.recipientemail) as recipientemail
     , coalesce(exist.senderemail, delta.senderemail) as senderemail
     , coalesce(exist.subject, delta.subject) as subject
     , case
          when exist.accepted_flag = true then true
          when delta.first_accepted_timestamp is not null then true
          else false
       end as accepted_flag
     , case
          when exist.rejected_flag = true then true
          when delta.first_rejected_timestamp is not null then true
          else false
       end as rejected_flag
     , case
          when exist.delivered_flag = true then true
          when delta.first_delivered_timestamp is not null then true
          else false
       end as delivered_flag
     , case
          when exist.failed_flag = true then true
          when delta.first_failed_timestamp is not null then true
          else false
       end as failed_flag
     , case
          when exist.opened_flag = true then true
          when delta.first_opened_timestamp is not null then true
          else false
       end as opened_flag
     , case
          when exist.clicked_flag = true then true
          when delta.first_clicked_timestamp is not null then true
          else false
       end as clicked_flag
     , case
          when exist.unsubscribed_flag = true then true
          when delta.first_unsubscribed_timestamp is not null then true
          else false
       end as unsubscribed_flag
     , case
          when exist.complained_flag = true then true
          when delta.first_complained_timestamp is not null then true
          else false
       end as complained_flag
     , case
         when exist.stored_flag = true then true
         when delta.first_stored_timestamp is not null then true
         else false
       end as stored_flag
     , coalesce(exist.first_accepted_timestamp, delta.first_accepted_timestamp) as first_accepted_timestamp
     , coalesce(exist.first_rejected_timestamp, delta.first_rejected_timestamp) as first_rejected_timestamp
     , coalesce(exist.first_delivered_timestamp, delta.first_delivered_timestamp) as first_delivered_timestamp
     , coalesce(exist.first_failed_timestamp, delta.first_failed_timestamp) as first_failed_timestamp
     , coalesce(exist.first_opened_timestamp, delta.first_opened_timestamp) as first_opened_timestamp
     , coalesce(exist.first_clicked_timestamp, delta.first_clicked_timestamp) as first_clicked_timestamp
     , coalesce(exist.first_unsubscribed_timestamp, delta.first_unsubscribed_timestamp) as first_unsubscribed_timestamp
     , coalesce(exist.first_complained_timestamp, delta.first_complained_timestamp) as first_complained_timestamp
     , coalesce(exist.first_stored_timestamp, delta.first_stored_timestamp) as first_stored_timestamp
     , delta.maxeventtimestamp as eventtimestamp_updated
from mailguncube_delta delta
join public.mailguncube exist
on delta.messageid = exist.messageid;


--============================================================================================================
-- Table: mailguncube_delta_insert
-- Description: This table contains all records from mailguncube_delta that are insert records.
--============================================================================================================

create temporary table mailguncube_delta_insert as
select delta.messageid
     , delta.applicationid
     , delta.recipientemail
     , delta.senderemail
     , delta.subject
     , case
         when delta.first_accepted_timestamp is not null then true
         else false
       end as accepted_flag
     , case
         when delta.first_rejected_timestamp is not null then true
         else false
       end as rejected_flag
     , case
         when delta.first_delivered_timestamp is not null then true
         else false
       end as delivered_flag
     , case
         when delta.first_failed_timestamp is not null then true
         else false
       end as failed_flag
     , case
         when delta.first_opened_timestamp is not null then true
         else false
       end as opened_flag
     , case
         when delta.first_clicked_timestamp is not null then true
         else false
         end as clicked_flag
     , case
         when delta.first_unsubscribed_timestamp is not null then true
         else false
       end as unsubscribed_flag
     , case
         when delta.first_complained_timestamp is not null then true
         else false
       end as complained_flag
     , case
         when delta.first_stored_timestamp is not null then true
         else false
       end as stored_flag
     , delta.first_accepted_timestamp
     , delta.first_rejected_timestamp
     , delta.first_delivered_timestamp
     , delta.first_failed_timestamp
     , delta.first_opened_timestamp
     , delta.first_clicked_timestamp
     , delta.first_unsubscribed_timestamp
     , delta.first_complained_timestamp
     , delta.first_stored_timestamp
     , delta.maxeventtimestamp as eventtimestamp_created
from mailguncube_delta delta
left join public.mailguncube exist
on delta.messageid = exist.messageid
where exist.messageid is null;


--============================================================================================================
-- Description: Update the mailguncube table based on the mailguncube_delta_update table.
--============================================================================================================

update public.mailguncube exist
set messageid = update.messageid
  , applicationid = update.applicationid
  , recipientemail = update.recipientemail
  , senderemail = update.senderemail
  , subject = update.subject
  , accepted_flag = update.accepted_flag
  , rejected_flag = update.rejected_flag
  , delivered_flag = update.delivered_flag
  , failed_flag = update.failed_flag
  , opened_flag = update.opened_flag
  , clicked_flag = update.clicked_flag
  , unsubscribed_flag = update.unsubscribed_flag
  , complained_flag = update.complained_flag
  , stored_flag = update.stored_flag
  , first_accepted_timestamp = update.first_accepted_timestamp
  , first_rejected_timestamp = update.first_rejected_timestamp
  , first_delivered_timestamp = update.first_delivered_timestamp
  , first_failed_timestamp = update.first_failed_timestamp
  , first_opened_timestamp = update.first_opened_timestamp
  , first_clicked_timestamp = update.first_clicked_timestamp
  , first_unsubscribed_timestamp = update.first_unsubscribed_timestamp
  , first_complained_timestamp = update.first_complained_timestamp
  , first_stored_timestamp = update.first_stored_timestamp
  , eventtimestamp_updated = update.eventtimestamp_updated
from mailguncube_delta_update update
where update.messageid = exist.messageid;


--============================================================================================================
-- Description: Insert into the mailguncube table based on the mailguncube_delta_insert table.
--============================================================================================================

insert into public.mailguncube
select *
from mailguncube_delta_insert;
