CREATE TABLE `t_server_notifys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `application` varchar(128) DEFAULT '',
  `server_name` varchar(128) DEFAULT NULL,
  `container_name` varchar(128) DEFAULT '',
  `node_name` varchar(128) NOT NULL DEFAULT '',
  `set_name` varchar(16) DEFAULT NULL,
  `set_area` varchar(16) DEFAULT NULL,
  `set_group` varchar(16) DEFAULT NULL,
  `server_id` varchar(100) DEFAULT NULL,
  `thread_id` varchar(20) DEFAULT NULL,
  `command` varchar(50) DEFAULT NULL,
  `result` text,
  `notifytime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_name` (`server_name`),
  KEY `servernoticetime_i_1` (`notifytime`),
  KEY `indx_1_server_id` (`server_id`),
  KEY `query_index` (`application`,`server_name`,`node_name`,`set_name`,`set_area`,`set_group`)
) ENGINE=InnoDB AUTO_INCREMENT=192 DEFAULT CHARSET=utf8;