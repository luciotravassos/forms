/* Verifica detalhes do logon, inclusive com a hora de conexão */
SELECT
--   rowidtochar(n.rowid),
         CHR (39) || s.SID || ',' || s.serial# || CHR (39) sid_serial,
         TO_CHAR (s.logon_time, 'DDth HH24:MI:SS') LOGON,
            FLOOR (last_call_et / 3600)
         || ':'
         || FLOOR (MOD (last_call_et, 3600) / 60)
         || ':'
         || MOD (MOD (last_call_et, 3600), 60) idle,
         s.username o_user, s.osuser os_user, s.status status,
         DECODE (lockwait, '', '', 'Y') lockwait, u.user_name apps_user,
         s.module || ' ' || s.action form_name
    FROM v$session s, v$process p, apps.fnd_logins n, apps.fnd_user u
   WHERE s.paddr = p.addr
     AND n.pid IS NOT NULL
     AND n.serial# IS NOT NULL
     AND n.login_name IS NOT NULL -- get rid of dups
     AND n.end_time IS NULL
     AND n.serial# = p.serial#
     AND n.pid = p.pid
     AND n.process_spid = p.spid
     --AND ROWNUM =1
     --AND p.spid = '17'
     --AND S.sid = '26'
     AND n.spid =
             s.process -- so we don't get hung sessions with old SID and SERIAL
     AND n.user_id = u.user_id
     AND TRUNC (s.logon_time) = TRUNC (n.start_time)
ORDER BY DECODE (NVL ('sort_order', '1'), '1', u.user_name, s.SID),
         TO_CHAR (s.logon_time, 'DDth - HH24:MI:SS')

