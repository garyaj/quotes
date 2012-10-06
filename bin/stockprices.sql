# MySQL dump 7.1
#
# Host: localhost    Database: stockprices
#--------------------------------------------------------
# Server version	3.22.32

#
# Table structure for table 'indicators'
#
CREATE TABLE indicators (
  scode varchar(10) DEFAULT '' NOT NULL,
  iname varchar(10) DEFAULT '' NOT NULL,
  date date DEFAULT '0000-00-00' NOT NULL,
  open float(10,2),
  high float(10,2),
  low float(10,2),
  close float(10,2),
  vol int(11),
  PRIMARY KEY (scode,iname,date)
);

#
# Table structure for table 'optcode'
#
CREATE TABLE optcode (
  scode varchar(10) DEFAULT '' NOT NULL,
  exmth int(11) DEFAULT '0' NOT NULL,
  str_pr int(11) DEFAULT '0' NOT NULL,
  p_c char(3) DEFAULT '' NOT NULL,
  stdate date DEFAULT '0000-00-00' NOT NULL,
  endate date DEFAULT '0000-00-00' NOT NULL,
  ocode varchar(10) DEFAULT '' NOT NULL,
  PRIMARY KEY (scode,exmth,str_pr,p_c,endate),
  KEY ocode (ocode,endate)
);

#
# Table structure for table 'optid'
#
CREATE TABLE optid (
  scode varchar(10) DEFAULT '' NOT NULL,
  exmth int(11) DEFAULT '0' NOT NULL,
  str_pr int(11) DEFAULT '0' NOT NULL,
  p_c char(3) DEFAULT '' NOT NULL,
  extype char(3),
  spc int(11),
  PRIMARY KEY (scode,exmth,str_pr,p_c)
);

#
# Table structure for table 'options'
#
CREATE TABLE options (
  ocode varchar(10) DEFAULT '' NOT NULL,
  scode varchar(10) DEFAULT '' NOT NULL,
  p_c char(3),
  exp_date date,
  str_price float(10,2),
  extype char(3),
  spc int(11),
  PRIMARY KEY (ocode)
);

#
# Table structure for table 'prices'
#
CREATE TABLE prices (
  code varchar(10) DEFAULT '' NOT NULL,
  pd_date date DEFAULT '0000-00-00' NOT NULL,
  pr_open float(10,2),
  pr_high float(10,2),
  pr_low float(10,2),
  pr_close float(10,2),
  pr_vol int(11),
  pr_cdf float(10,2),
  pr_oi int(11),
  PRIMARY KEY (code,pd_date)
);

#
# Table structure for table 'share'
#
CREATE TABLE share (
  scode varchar(10) DEFAULT '' NOT NULL,
  sdesc varchar(50),
  PRIMARY KEY (scode)
);

#
# Table structure for table 'warrants'
#
CREATE TABLE warrants (
  wcode varchar(10) DEFAULT '' NOT NULL,
  scode varchar(10) DEFAULT '' NOT NULL,
  p_c char(3),
  exp_date date,
  str_price float(10,2),
  extype char(3),
  wps float(10,2),
  PRIMARY KEY (wcode)
);

