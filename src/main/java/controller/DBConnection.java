package controller;

import java.sql.Connection;
import java.sql.DriverManager;
import java.net.URI;

public class DBConnection {

    
    private static final String RAILWAY_JDBC = 
        "jdbc:postgresql://interchange.proxy.rlwy.net:33911/railway?sslmode=require";
    private static final String RAILWAY_USER = "postgres";
    private static final String RAILWAY_PASS = "pTEZzndwjlCKVOpLGJmWqGGkoMFgNmSI";

 
    private static final String LOCAL_JDBC = "jdbc:postgresql://localhost:5432/bank";
    private static final String LOCAL_USER = "postgres";
    private static final String LOCAL_PASS = "vikas29";

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");

            String dbUrl = System.getenv("DATABASE_URL");

            if (dbUrl != null && !dbUrl.isEmpty()) {
            
                try {
                    URI uri = new URI(dbUrl);
                    String host = uri.getHost();
                    int    port = uri.getPort();
                    String path = uri.getPath().substring(1);
                    String user = uri.getUserInfo().split(":")[0];
                    String pass = uri.getUserInfo().split(":")[1];
                    String jdbc = "jdbc:postgresql://" + host + ":" + port + "/" + path + "?sslmode=require";
                    conn = DriverManager.getConnection(jdbc, user, pass);
                    System.out.println("✅ Railway DB Connected via ENV!");
                } catch (Exception e) {
                   
                    System.out.println("⚠️ ENV parse failed, trying direct...");
                    conn = DriverManager.getConnection(RAILWAY_JDBC, RAILWAY_USER, RAILWAY_PASS);
                    System.out.println("✅ Railway DB Connected via Direct!");
                }
            } else {
              
                try {
                    conn = DriverManager.getConnection(LOCAL_JDBC, LOCAL_USER, LOCAL_PASS);
                    System.out.println("✅ Local DB Connected!");
                } catch (Exception le) {
                    // Local failed — try Railway direct
                    System.out.println("⚠️ Local failed, trying Railway direct...");
                    conn = DriverManager.getConnection(RAILWAY_JDBC, RAILWAY_USER, RAILWAY_PASS);
                    System.out.println("✅ Railway DB Connected via Direct Fallback!");
                }
            }

        } catch (Exception e) {
            System.out.println("❌ All DB connections failed: " + e.getMessage());
            e.printStackTrace();
        }
        return conn;
    }
}