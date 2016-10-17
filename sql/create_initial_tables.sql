-- create initial mailgun events table
drop table if exists mailgun.mailgun_events;
CREATE TABLE mailgun.mailgun_events (
   applicationid UUID,
   eventtimestamp BIGINT,
   recipientemail CHARACTER VARYING(1000),
   senderemail CHARACTER VARYING,
   subject CHARACTER VARYING,
   clickurl CHARACTER VARYING,
   eventstatus CHARACTER VARYING,
   id CHARACTER VARYING,
   messageid CHARACTER VARYING,
   clientos CHARACTER VARYING,
   devicetype CHARACTER VARYING,
   clientname CHARACTER VARYING,
   clienttype CHARACTER VARYING,
   useragent CHARACTER VARYING
);

-- create index on applicationid
create index ndx_mailgun_events_application_id on mailgun.mailgun_events (applicationid);

-- create initial mailguncube table
drop table if exists mailgun.mailguncube;
create table mailgun.mailguncube (
     messageid varchar
   , applicationid uuid
   , recipientemail varchar
   , recipientemaildomain varchar
   , recipientname varchar
   , senderemail varchar
   , senderemaildomain varchar
   , sendername varchar
   , subject varchar
   , accepted_flag boolean
   , rejected_flag boolean
   , delivered_flag boolean
   , failed_flag boolean
   , opened_flag boolean
   , clicked_flag boolean
   , unsubscribed_flag boolean
   , complained_flag boolean
   , stored_flag boolean
   , first_accepted_timestamp timestamp
   , first_rejected_timestamp timestamp
   , first_delivered_timestamp timestamp
   , first_failed_timestamp timestamp
   , first_opened_timestamp timestamp
   , first_clicked_timestamp timestamp
   , first_unsubscribed_timestamp timestamp
   , first_complained_timestamp timestamp
   , first_stored_timestamp timestamp
   , eventtimestamp_created bigint
   , eventtimestamp_updated bigint); 

-- create index on applicationid
create index ndx_mailguncube_application_id on mailgun.mailguncube (applicationid);

-- create unsubscribe table
drop table if exists mailgun.mailgun_unsubscribe;
create table mailgun.mailgun_unsubscribe (
     email varchar
   , messageid varchar
   , id varchar
   , event varchar
   , url varchar
   , timestamp_epoch bigint);
