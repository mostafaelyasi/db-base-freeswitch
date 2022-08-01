--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.11
-- Dumped by pg_dump version 9.6.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: agent_status; Type: TYPE; Schema: public; Owner: fsuser
--

CREATE TYPE public.agent_status AS ENUM (
    'Logged Out',
    'Available',
    'Available (On Demand)',
    'On Break'
);


ALTER TYPE public.agent_status OWNER TO fsuser;

--
-- Name: agent_type; Type: TYPE; Schema: public; Owner: fsuser
--

CREATE TYPE public.agent_type AS ENUM (
    'callback',
    'uuid-standby'
);


ALTER TYPE public.agent_type OWNER TO fsuser;

--
-- Name: queue_strategy; Type: TYPE; Schema: public; Owner: fsuser
--

CREATE TYPE public.queue_strategy AS ENUM (
    'ring-all',
    'longest-idle-agent',
    'round-robin',
    'top-down',
    'agent-with-least-talk-time',
    'agent-with-fewest-calls',
    'sequentially-by-agent-order',
    'random',
    'ring-progressively'
);


ALTER TYPE public.queue_strategy OWNER TO fsuser;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.admin (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    session text
);


ALTER TABLE public.admin OWNER TO fsuser;

--
-- Name: cc_agents; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.cc_agents (
    id integer NOT NULL,
    name character varying,
    type public.agent_type,
    contact character varying NOT NULL,
    status public.agent_status,
    max_no_answer integer DEFAULT 3 NOT NULL,
    wrap_up_time integer DEFAULT 10 NOT NULL,
    reject_delay_time integer DEFAULT 3 NOT NULL,
    busy_delay_time integer DEFAULT 60 NOT NULL,
    no_answer_delay_time integer DEFAULT 5 NOT NULL,
    reserve_agents character varying DEFAULT 'false'::character varying NOT NULL,
    truncate_agents_on_load character varying DEFAULT 'false'::character varying NOT NULL,
    truncate_tiers_on_load character varying DEFAULT 'false'::character varying NOT NULL
);


ALTER TABLE public.cc_agents OWNER TO fsuser;

--
-- Name: cc_agents_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.cc_agents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cc_agents_id_seq OWNER TO fsuser;

--
-- Name: cc_agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.cc_agents_id_seq OWNED BY public.cc_agents.id;


--
-- Name: cc_queues; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.cc_queues (
    id integer NOT NULL,
    name character varying,
    strategy public.queue_strategy,
    moh_sound character varying DEFAULT '$${hold_music}'::character varying NOT NULL,
    record_template character varying,
    time_base_score character varying DEFAULT 'queue'::character varying NOT NULL,
    max_wait_time integer DEFAULT 0 NOT NULL,
    max_wait_time_wna integer DEFAULT 0 NOT NULL,
    max_wait_time_wna_tr integer DEFAULT 5 NOT NULL,
    tier_rules_apply character varying DEFAULT 'false'::character varying NOT NULL,
    tier_rule_wait_second integer DEFAULT 300 NOT NULL,
    tier_rule_wait_ml character varying DEFAULT 'true'::character varying NOT NULL,
    tier_rule_no_agent_no_wait character varying DEFAULT 'false'::character varying NOT NULL,
    discard_abandoned_after integer DEFAULT 60 NOT NULL,
    abandoned_resume_allowed character varying DEFAULT 'false'::character varying NOT NULL,
    ring_progressively_delay integer DEFAULT 60 NOT NULL
);


ALTER TABLE public.cc_queues OWNER TO fsuser;

--
-- Name: cc_queues_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.cc_queues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cc_queues_id_seq OWNER TO fsuser;

--
-- Name: cc_queues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.cc_queues_id_seq OWNED BY public.cc_queues.id;


--
-- Name: cc_settings; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.cc_settings (
    id integer NOT NULL,
    odbc_dsn character varying(1024),
    dbname character varying
);


ALTER TABLE public.cc_settings OWNER TO fsuser;

--
-- Name: cc_tiers; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.cc_tiers (
    id integer NOT NULL,
    agent character varying NOT NULL,
    queue character varying NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    "position" integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.cc_tiers OWNER TO fsuser;

--
-- Name: cc_tiers_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.cc_tiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cc_tiers_id_seq OWNER TO fsuser;

--
-- Name: cc_tiers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.cc_tiers_id_seq OWNED BY public.cc_tiers.id;


--
-- Name: cdr; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.cdr (
    id integer NOT NULL,
    local_ip_v4 inet NOT NULL,
    caller_id_name character varying,
    caller_id_number character varying,
    destination_number character varying NOT NULL,
    context character varying NOT NULL,
    start_stamp timestamp with time zone NOT NULL,
    answer_stamp timestamp with time zone,
    end_stamp timestamp with time zone NOT NULL,
    duration integer NOT NULL,
    billsec integer NOT NULL,
    hangup_cause character varying NOT NULL,
    uuid uuid NOT NULL,
    bleg_uuid uuid,
    accountcode character varying,
    read_codec character varying,
    write_codec character varying,
    sip_hangup_disposition character varying,
    ani character varying,
    endpoint_disposition character varying(32)
);


ALTER TABLE public.cdr OWNER TO fsuser;

--
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.cdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cdr_id_seq OWNER TO fsuser;

--
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.cdr_id_seq OWNED BY public.cdr.id;


--
-- Name: dialplan_xml; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.dialplan_xml (
    id integer NOT NULL,
    dp_domain text,
    dp_context text,
    dp_name text,
    dp_continue text DEFAULT 'false'::text,
    dp_condtype text DEFAULT 'field'::text,
    dp_condvalue text DEFAULT 'destination_number'::text,
    dp_expr text,
    dp_break text DEFAULT 'on-false'::text,
    dp_xml text,
    enabled boolean DEFAULT false
);


ALTER TABLE public.dialplan_xml OWNER TO fsuser;

--
-- Name: dialplan_xml_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.dialplan_xml_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dialplan_xml_id_seq OWNER TO fsuser;

--
-- Name: dialplan_xml_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.dialplan_xml_id_seq OWNED BY public.dialplan_xml.id;


--
-- Name: directory; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.directory (
    domain character varying(32) NOT NULL,
    id character varying(32) NOT NULL,
    "number-alias" character varying(32) DEFAULT NULL::character varying,
    mailbox character varying(64) DEFAULT NULL::character varying,
    cidr character varying(64) DEFAULT NULL::character varying,
    "password" character varying(64) DEFAULT NULL::character varying,
    toll_allow character varying(32) DEFAULT NULL::character varying,
    user_context character varying(32) DEFAULT NULL::character varying,
    default_gateway character varying(32) DEFAULT NULL::character varying,
    effective_caller_id_name character varying(512) DEFAULT NULL::character varying,
    effective_caller_id_number character varying(64) DEFAULT NULL::character varying,
    outbound_caller_id_name character varying(512) DEFAULT NULL::character varying,
    outbound_caller_id_number character varying(64) DEFAULT NULL::character varying,
    callgroup character varying(64) DEFAULT NULL::character varying,
    tls character varying(8) DEFAULT NULL::character varying,
    codec character varying(128) DEFAULT NULL::character varying,
    accountcode character varying(64) DEFAULT NULL::character varying,
    username character varying(32) DEFAULT NULL::character varying,
    fullname character varying(200) DEFAULT NULL::character varying,
    "vm-password" character varying(128) DEFAULT NULL::character varying,
    fwd_type character varying(64) DEFAULT NULL::character varying,
    fwd_number character varying(14) DEFAULT NULL::character varying,
    uservar1 character varying(64) DEFAULT NULL::character varying,
    uservar2 character varying(64) DEFAULT NULL::character varying,
    uservar3 character varying(64) DEFAULT NULL::character varying,
    uservar4 character varying(512) DEFAULT NULL::character varying,
    uservar5 character varying(512) DEFAULT NULL::character varying,
    uservar6 character varying(8) DEFAULT NULL::character varying,
    uservar7 character varying(512) DEFAULT NULL::character varying,
    branch character varying(255) DEFAULT NULL::character varying
);


ALTER TABLE public.directory OWNER TO fsuser;

--
-- Name: distributor; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.distributor (
    id integer NOT NULL,
    list character varying,
    node character varying,
    weight character varying
);


ALTER TABLE public.distributor OWNER TO fsuser;

--
-- Name: distributor_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.distributor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distributor_id_seq OWNER TO fsuser;

--
-- Name: distributor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.distributor_id_seq OWNED BY public.distributor.id;


--
-- Name: fifo; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.fifo (
    id integer NOT NULL,
    name character varying,
    importance integer DEFAULT 0,
    timeout integer DEFAULT 20,
    simo integer DEFAULT 1,
    lag integer DEFAULT 5,
    member_wait character varying DEFAULT 'nowait'::character varying,
    members character varying
);


ALTER TABLE public.fifo OWNER TO fsuser;

--
-- Name: fifo_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.fifo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fifo_id_seq OWNER TO fsuser;

--
-- Name: fifo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.fifo_id_seq OWNED BY public.fifo.id;


--
-- Name: gateways; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.gateways (
    id integer NOT NULL,
    profile character varying,
    gw_name character varying,
    type character varying,
    name character varying,
    value character varying,
    enable boolean DEFAULT false NOT NULL,
    active boolean DEFAULT false
);


ALTER TABLE public.gateways OWNER TO fsuser;

--
-- Name: gateways_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.gateways_id_seq
    START WITH 1
    INCREMENT BY 5
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.gateways_id_seq OWNER TO fsuser;

--
-- Name: gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.gateways_id_seq OWNED BY public.gateways.id;


--
-- Name: gw_dummy; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.gw_dummy (
    profile character varying,
    gw_name character varying,
    type character varying,
    name character varying,
    value character varying,
    enable boolean
);


ALTER TABLE public.gw_dummy OWNER TO fsuser;

--
-- Name: incoming_map; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.incoming_map (
    id character varying(8) NOT NULL,
    did character varying(32) DEFAULT NULL::character varying,
    did_domain character varying(64) DEFAULT '$${domain}'::character varying,
    did_pre_execute character varying(512) DEFAULT 'ALL_TC'::character varying,
    did_app character varying(32) DEFAULT NULL::character varying,
    did_fail character varying(512) DEFAULT NULL::character varying,
    did_timeout character varying(8) DEFAULT NULL::character varying,
    did_data character varying(512) DEFAULT NULL::character varying,
    did_var character varying(512) DEFAULT NULL::character varying,
    did_post_execute character varying(512) DEFAULT 'ALL_HG'::character varying,
    did_branch character varying(64) DEFAULT NULL::character varying,
    did_codec character varying(128) DEFAULT 'PCMA'::character varying
);


ALTER TABLE public.incoming_map OWNER TO fsuser;

--
-- Name: ivr_entry; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.ivr_entry (
    id integer NOT NULL,
    menu_name character varying(32),
    action character varying(32),
    digits character varying(32),
    param character varying
);


ALTER TABLE public.ivr_entry OWNER TO fsuser;

--
-- Name: ivr_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.ivr_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ivr_entry_id_seq OWNER TO fsuser;

--
-- Name: ivr_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.ivr_entry_id_seq OWNED BY public.ivr_entry.id;


--
-- Name: ivr_menus; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.ivr_menus (
    id integer NOT NULL,
    name character varying NOT NULL,
    greet_long character varying(256),
    greet_short character varying(256),
    invalid_sound character varying(256),
    exit_sound character varying(256),
    inter_digit_timeout character varying(4),
    timeout character varying(4),
    confirm_macro character varying(256),
    confirm_key character varying(4),
    confirm_attempts character varying(4),
    max_failures character varying(4),
    max_timeouts character varying(4),
    exec_on_max_failures character varying(256),
    exec_on_max_timeouts character varying(256),
    tts_engine character varying(256),
    tts_voice character varying(256),
    digit_len character varying(16)
);


ALTER TABLE public.ivr_menus OWNER TO fsuser;

--
-- Name: ivr_menus_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.ivr_menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ivr_menus_id_seq OWNER TO fsuser;

--
-- Name: ivr_menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.ivr_menus_id_seq OWNED BY public.ivr_menus.id;


--
-- Name: out_map; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.out_map (
    id integer NOT NULL,
    out_prepend character varying(32),
    out_prefix character varying(8),
    out_pattern text,
    out_type character varying(32),
    out_codec character varying(32) DEFAULT 'PCMA'::character varying,
    out_cid character varying(32),
    out_gw character varying(32),
    out_toll_allow character varying(32)
);


ALTER TABLE public.out_map OWNER TO fsuser;

--
-- Name: out_map_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.out_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.out_map_id_seq OWNER TO fsuser;

--
-- Name: out_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.out_map_id_seq OWNED BY public.out_map.id;


--
-- Name: queuelog; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.queuelog (
    id integer NOT NULL,
    cc_member_uuid uuid NOT NULL,
    cc_agent_uuid uuid,
    cc_queue_joined_epoch integer NOT NULL,
    cc_queue_answered_epoch integer,
    cc_queue_terminated_epoch integer,
    cc_queue_canceled_epoch integer,
    cc_side character varying NOT NULL,
    caller_id character varying,
    cc_queue character varying NOT NULL,
    cc_agent character varying,
    waitsec integer NOT NULL,
    duration integer NOT NULL,
    billsec integer NOT NULL,
    cc_cause character varying NOT NULL,
    cc_cancel_reason character varying,
    hangup_cause character varying NOT NULL,
    cc_agent_bridged character varying,
    sip_hangup_disposition character varying,
    cc_record_filename character varying
);


ALTER TABLE public.queuelog OWNER TO fsuser;

--
-- Name: queuelog_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.queuelog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.queuelog_id_seq OWNER TO fsuser;

--
-- Name: queuelog_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.queuelog_id_seq OWNED BY public.queuelog.id;


--
-- Name: sip_profiles; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.sip_profiles (
    id integer NOT NULL,
    profile character varying,
    type character varying,
    name character varying,
    value character varying,
    enable boolean DEFAULT false NOT NULL,
    active boolean DEFAULT true
);


ALTER TABLE public.sip_profiles OWNER TO fsuser;

--
-- Name: sip_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.sip_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sip_profiles_id_seq OWNER TO fsuser;

--
-- Name: sip_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.sip_profiles_id_seq OWNED BY public.sip_profiles.id;


--
-- Name: user_map; Type: TABLE; Schema: public; Owner: fsuser
--

CREATE TABLE public.user_map (
    id integer NOT NULL,
    did_start character varying(8) NOT NULL,
    did_end character varying(8) NOT NULL,
    type character varying(16) DEFAULT NULL::character varying,
    data character varying(512) DEFAULT NULL::character varying,
    codec character varying(128) DEFAULT NULL::character varying,
    branch character varying(128) DEFAULT NULL::character varying
);


ALTER TABLE public.user_map OWNER TO fsuser;

--
-- Name: user_map_id_seq; Type: SEQUENCE; Schema: public; Owner: fsuser
--

CREATE SEQUENCE public.user_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_map_id_seq OWNER TO fsuser;

--
-- Name: user_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fsuser
--

ALTER SEQUENCE public.user_map_id_seq OWNED BY public.user_map.id;


--
-- Name: cc_agents id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_agents ALTER COLUMN id SET DEFAULT nextval('public.cc_agents_id_seq'::regclass);


--
-- Name: cc_queues id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_queues ALTER COLUMN id SET DEFAULT nextval('public.cc_queues_id_seq'::regclass);


--
-- Name: cc_tiers id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_tiers ALTER COLUMN id SET DEFAULT nextval('public.cc_tiers_id_seq'::regclass);


--
-- Name: cdr id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cdr ALTER COLUMN id SET DEFAULT nextval('public.cdr_id_seq'::regclass);


--
-- Name: dialplan_xml id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.dialplan_xml ALTER COLUMN id SET DEFAULT nextval('public.dialplan_xml_id_seq'::regclass);


--
-- Name: distributor id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.distributor ALTER COLUMN id SET DEFAULT nextval('public.distributor_id_seq'::regclass);


--
-- Name: fifo id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.fifo ALTER COLUMN id SET DEFAULT nextval('public.fifo_id_seq'::regclass);


--
-- Name: gateways id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.gateways ALTER COLUMN id SET DEFAULT nextval('public.gateways_id_seq'::regclass);


--
-- Name: ivr_entry id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.ivr_entry ALTER COLUMN id SET DEFAULT nextval('public.ivr_entry_id_seq'::regclass);


--
-- Name: ivr_menus id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.ivr_menus ALTER COLUMN id SET DEFAULT nextval('public.ivr_menus_id_seq'::regclass);


--
-- Name: out_map id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.out_map ALTER COLUMN id SET DEFAULT nextval('public.out_map_id_seq'::regclass);


--
-- Name: queuelog id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.queuelog ALTER COLUMN id SET DEFAULT nextval('public.queuelog_id_seq'::regclass);


--
-- Name: sip_profiles id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.sip_profiles ALTER COLUMN id SET DEFAULT nextval('public.sip_profiles_id_seq'::regclass);


--
-- Name: user_map id; Type: DEFAULT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.user_map ALTER COLUMN id SET DEFAULT nextval('public.user_map_id_seq'::regclass);


--
-- Name: admin admin_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_id_key UNIQUE (id);


--
-- Name: cc_agents cc_agents_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_agents
    ADD CONSTRAINT cc_agents_id_key UNIQUE (id);


--
-- Name: cc_agents cc_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_agents
    ADD CONSTRAINT cc_agents_pkey PRIMARY KEY (id);


--
-- Name: cc_queues cc_queues_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_queues
    ADD CONSTRAINT cc_queues_id_key UNIQUE (id);


--
-- Name: cc_queues cc_queues_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_queues
    ADD CONSTRAINT cc_queues_pkey PRIMARY KEY (id);


--
-- Name: cc_tiers cc_tiers_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_tiers
    ADD CONSTRAINT cc_tiers_id_key UNIQUE (id);


--
-- Name: cc_tiers cc_tiers_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cc_tiers
    ADD CONSTRAINT cc_tiers_pkey PRIMARY KEY (id);


--
-- Name: cdr cdr_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.cdr
    ADD CONSTRAINT cdr_pkey PRIMARY KEY (id);


--
-- Name: dialplan_xml dialplan_xml_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.dialplan_xml
    ADD CONSTRAINT dialplan_xml_id_key UNIQUE (id);


--
-- Name: dialplan_xml dialplan_xml_id_key1; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.dialplan_xml
    ADD CONSTRAINT dialplan_xml_id_key1 UNIQUE (id);


--
-- Name: directory directory_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.directory
    ADD CONSTRAINT directory_id_key UNIQUE (id);


--
-- Name: distributor distributor_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.distributor
    ADD CONSTRAINT distributor_id_key UNIQUE (id);


--
-- Name: distributor distributor_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.distributor
    ADD CONSTRAINT distributor_pkey PRIMARY KEY (id);


--
-- Name: fifo fifo_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.fifo
    ADD CONSTRAINT fifo_id_key UNIQUE (id);


--
-- Name: fifo fifo_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.fifo
    ADD CONSTRAINT fifo_pkey PRIMARY KEY (id);


--
-- Name: gateways gateways_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.gateways
    ADD CONSTRAINT gateways_id_key UNIQUE (id);


--
-- Name: gateways gateways_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.gateways
    ADD CONSTRAINT gateways_pkey PRIMARY KEY (id);


--
-- Name: incoming_map incoming_map_did_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.incoming_map
    ADD CONSTRAINT incoming_map_did_key UNIQUE (did);


--
-- Name: incoming_map incoming_map_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.incoming_map
    ADD CONSTRAINT incoming_map_pkey PRIMARY KEY (id);


--
-- Name: ivr_entry ivr_entry_id_menu_name_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.ivr_entry
    ADD CONSTRAINT ivr_entry_id_menu_name_key UNIQUE (id, menu_name);


--
-- Name: ivr_menus ivr_menus_id_name_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.ivr_menus
    ADD CONSTRAINT ivr_menus_id_name_key UNIQUE (id, name);


--
-- Name: out_map out_map_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.out_map
    ADD CONSTRAINT out_map_id_key UNIQUE (id);


--
-- Name: out_map out_map_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.out_map
    ADD CONSTRAINT out_map_pkey PRIMARY KEY (id);


--
-- Name: queuelog queuelog_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.queuelog
    ADD CONSTRAINT queuelog_pkey PRIMARY KEY (id);


--
-- Name: sip_profiles sip_profiles_id_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.sip_profiles
    ADD CONSTRAINT sip_profiles_id_key UNIQUE (id);


--
-- Name: sip_profiles sip_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.sip_profiles
    ADD CONSTRAINT sip_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_map user_map_did_end_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.user_map
    ADD CONSTRAINT user_map_did_end_key UNIQUE (did_end);


--
-- Name: user_map user_map_did_start_key; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.user_map
    ADD CONSTRAINT user_map_did_start_key UNIQUE (did_start);


--
-- Name: user_map user_map_pkey; Type: CONSTRAINT; Schema: public; Owner: fsuser
--

ALTER TABLE ONLY public.user_map
    ADD CONSTRAINT user_map_pkey PRIMARY KEY (id);


--
-- Data for Name: directory; Type: TABLE DATA; Schema: public; Owner: fsuser
--

INSERT INTO public.directory(domain,id,"number-alias","password","user_context", "effective_caller_id_name", "effective_caller_id_number","outbound_caller_id_name" ,"outbound_caller_id_number", callgroup,accountcode,toll_allow) VALUES ('172.20.104.34', 1020,1020,1020,'default', 'Extension 1020',1020,'FS_Test1023',00001020,'default',1020,'domestic,international,local');
INSERT INTO public.directory(domain,id,"number-alias","password","user_context", "effective_caller_id_name", "effective_caller_id_number","outbound_caller_id_name" ,"outbound_caller_id_number", callgroup,accountcode,toll_allow) VALUES ('172.20.104.34', 1021,1021,1021,'default', 'Extension 1021',1021,'FS_Test1023',00001021,'default',1021,'domestic,international,local');
INSERT INTO public.directory(domain,id,"number-alias","password","user_context", "effective_caller_id_name", "effective_caller_id_number","outbound_caller_id_name" ,"outbound_caller_id_number", callgroup,accountcode,toll_allow) VALUES ('172.20.104.34', 1022,1022,1022,'default', 'Extension 1022',1022,'FS_Test1023',00001022,'default',1022,'domestic,international,local');
INSERT INTO public.directory(domain,id,"number-alias","password","user_context", "effective_caller_id_name", "effective_caller_id_number","outbound_caller_id_name" ,"outbound_caller_id_number", callgroup,accountcode,toll_allow) VALUES ('172.20.104.34', 1023,1023,1023,'default', 'Extension 1023',1023,'FS_Test1023',00001023,'default',1023,'domestic,international,local');


--
-- PostgreSQL database dump complete
--
