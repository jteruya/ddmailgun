-- create initial mailguncube table
create table public.mailguncube (
     messageid varchar
   , applicationid uuid
   , recipientemail varchar
   , senderemail varchar
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