<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
	<% request.setCharacterEncoding("utf-8"); %>
    <%@ page import="java.sql.*" %>
    <%@ page import="javax.sql.*" %>
    <%@ page import="javax.naming.*" %>
    
    <%@ page import="java.util.*" %>
    <%@ page import="java.text.SimpleDateFormat" %>
    <%@ page import="java.io.*" %>
    <%@ page import="java.lang.*" %>
    <%@ page import="java.net.HttpURLConnection" %>
    <%@ page import="java.net.MalformedURLException" %>
    <%@ page import="java.net.URL" %>
    <%@ page import="org.json.simple.JSONArray" %>
    <%@ page import="org.json.simple.JSONObject" %>
    <%@ page import="org.json.simple.parser.JSONParser" %>
    <%@ page import="org.json.simple.parser.ParseException" %>
    <%!
	    public static Connection conn = null; // Connection object
		public static Statement stmt = null;	// Statement object
	    public static String sql = ""; // an SQL statement 
	    public static ArrayList<Object[]> commits_url_list = new ArrayList<Object[]>();
	    public static String github_token = "";	// 깃헙 토큰 추가!!!
    %>
    
    <%!
	    static Object get_json_obj(String jsonStr) {
			JSONParser parser = new JSONParser();
			Object obj;
			try {
				obj = parser.parse(jsonStr);
				JSONObject jsonObj = (JSONObject) obj;
				return jsonObj;
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return null;
		}
	
		static Object get_json_array_obj(String jsonStr) {
			JSONParser parser = new JSONParser();
			Object obj;
			try {
				obj = parser.parse(jsonStr);
				JSONArray jsonObj = (JSONArray) obj;
				return jsonObj;
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return null;
		}
	
		static HashMap<String,Object> get_user_info_in_json(JSONObject jsonObj) {
			HashMap<String,Object> user_info = new HashMap<String,Object>();//HashMap생성
			user_info.put("github_id", (String) jsonObj.get("login"));
			user_info.put("avatar_url", (String) jsonObj.get("avatar_url"));
			user_info.put("name", (String) jsonObj.get("name"));
			user_info.put("company", (String) jsonObj.get("company"));
			user_info.put("bio", (String) jsonObj.get("bio"));
			user_info.put("location", (String) jsonObj.get("location"));
			user_info.put("user_github_url", (String) jsonObj.get("html_url"));
			user_info.put("ghchart_url", "https://ghchart.rshah.org/"+(String) jsonObj.get("login"));
			Long followers = (Long) jsonObj.get("followers");
			user_info.put("followers", followers);
			user_info.put("member_level", "1");
			user_info.put("exp", 1);
			user_info.put("commit_count_acc", 0);
			user_info.put("group_cnt", 0);
			user_info.put("user_rank_id", null);
			user_info.put("created_at", (String) jsonObj.get("created_at"));
			user_info.put("updated_at", (String) jsonObj.get("updated_at"));
			
			HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
			res = convert_insert_format(user_info);
			
			return res;
		}
	
		static HashMap<String,Object> convert_insert_format(HashMap<String,Object> info) {
			if (info.containsKey("created_at")) {
				String created_at = (String) info.get("created_at");
				created_at = created_at.replaceAll("[TZ]", " ");
				created_at = created_at.trim();
				info.put("created_at", created_at);
			}
			if (info.containsKey("updated_at")) {
				String updated_at = (String) info.get("updated_at");
				updated_at = updated_at.replaceAll("[TZ]", " ");
				updated_at = updated_at.trim();
				info.put("updated_at", updated_at);
			}
			if (info.containsKey("updated_at")) {
				String updated_at = (String) info.get("updated_at");
				updated_at = updated_at.replaceAll("[TZ]", " ");
				updated_at = updated_at.trim();
				info.put("updated_at", updated_at);
			}
			if (info.containsKey("commit_date")) {
				String commit_date = (String) info.get("commit_date");
				commit_date = commit_date.replaceAll("[TZ]", " ");
				commit_date = commit_date.trim();
				info.put("commit_date", commit_date);
			}
			
			HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
			Iterator<Map.Entry<String, Object>> it = info.entrySet().iterator();
	        while (it.hasNext()) {
	        	String key = it.next().getKey();
	    		if (info.get(key) != null){
	    			if (info.get(key) instanceof String) {
	            	String value = (String) info.get(key);
	            	it.remove();
	            	res.put(key, String.format("'%s'", value));
	    			}
	    			else {
	    				res.put(key, info.get(key));
	    			}
	        	}
	        }
			
			return res;
		}
	
	
		static HashMap<String,Object> get_user_info(String github_id) {
			ResultSet rs = null;
			HashMap<String,Object> user_info = new HashMap<String,Object>();	//HashMap생성
			try {
				sql = "select github_id "
						+ "from member "
						+ "where github_id = '" + github_id + "' "
						+ "and github_id in ( "
						+ "select M.github_id "
						+ "from member M)";
				
				rs = stmt.executeQuery(sql);
				if (!rs.isBeforeFirst()) {
					URL url= new URL("https://api.github.com/users/" + github_id);
					HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
					httpConn.setRequestMethod("GET");
					
					httpConn.setRequestProperty("Accept", "application/vnd.github+json");
					httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
					
					InputStream responseStream = httpConn.getResponseCode() / 100 == 2
							? httpConn.getInputStream()
							: httpConn.getErrorStream();
					Scanner s = new Scanner(responseStream).useDelimiter("\\A");
					String response = s.hasNext() ? s.next() : "";
					JSONObject jsonObj = (JSONObject) get_json_obj(response);
					//HashMap<String,Object> user_info = new HashMap<String,Object>();	//HashMap생성
					// message = Not Found 인 경우 (깃헙 내 아이디가 존재하지 않는 경우)
					if (jsonObj.get("message") != null && ((String) jsonObj.get("message")).equals("Not Found")) {
						user_info.put("message", "Not Found");
						return user_info;
					}
					user_info = get_user_info_in_json(jsonObj);
					rs.close();
					return user_info;
				}
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SQLException ex2) {
				// System.println("sql error = " + ex2.getMessage());
				// System.exit(1);
			}	
			return null;
		}
		
		static int get_count_info(String requests_url) {
			// 레포별 commit, issue, pr 개수
			try {
				URL url= new URL(requests_url);
				HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
				httpConn.setRequestMethod("GET");
				
				httpConn.setRequestProperty("Accept", "application/vnd.github+json");
				httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
				
				InputStream responseStream = httpConn.getResponseCode() / 100 == 2
						? httpConn.getInputStream()
						: httpConn.getErrorStream();
				Scanner s = new Scanner(responseStream).useDelimiter("\\A");
				String response = s.hasNext() ? s.next() : "";
				if (response.trim().charAt(0) == '[') {
					JSONArray jsonArray = (JSONArray) get_json_array_obj(response);
					return jsonArray.size();
				} else if ((response.trim().charAt(0) == '{')) {
					return 0;
				}
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (NullPointerException e1) {
				// System.out.println(e1);
				e1.printStackTrace();
			}
			return 0;
		}	
	
		static void insert_repo_info(String github_id) {
			commits_url_list.clear();
			String select_sql = "select max(repository_id) from repository";
			int repo_id = 0;
			try {
				ResultSet rs = stmt.executeQuery(select_sql);
				rs.next();
				String repo_id_str = rs.getString(1);
				repo_id = Integer.parseInt(repo_id_str);
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			try {
				URL url= new URL("https://api.github.com/users/" + github_id + "/repos");
				HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
				httpConn.setRequestMethod("GET");
				
				httpConn.setRequestProperty("Accept", "application/vnd.github+json");
				httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
				
				InputStream responseStream = httpConn.getResponseCode() / 100 == 2
						? httpConn.getInputStream()
						: httpConn.getErrorStream();
				Scanner s = new Scanner(responseStream).useDelimiter("\\A");
				String response = s.hasNext() ? s.next() : "";
				JSONArray jsonArray = (JSONArray) get_json_array_obj(response);
				for (int i = 0; i < jsonArray.size(); i++) {
					JSONObject jsonObject = (JSONObject) jsonArray.get(i);
					
					String commits_url = ((String)jsonObject.get("commits_url")).replace("{/sha}","");
					String issues_url = ((String)jsonObject.get("issues_url")).replace("{/number}","");
					String pulls_url = ((String)jsonObject.get("pulls_url")).replace("{/number}","");
					int commit_cnt = get_count_info(commits_url);
					int issue_cnt = get_count_info(issues_url);
					int pulls_cnt = get_count_info(pulls_url);
					commits_url_list.add(new Object[] {commits_url, repo_id + 1});	// commit_url 저장
					HashMap<String,Object> repo_info = new HashMap<String,Object>();//HashMap생성
					repo_info.put("repository_id", repo_id + 1); repo_info.put("repo_name", (String) jsonObject.get("name"));
					repo_info.put("repo_url", (String) jsonObject.get("html_url"));
					repo_info.put("fork_count", (long) jsonObject.get("forks_count"));
					repo_info.put("stargazers_count", (long) jsonObject.get("stargazers_count"));
					repo_info.put("created_at", (String) jsonObject.get("created_at"));
					repo_info.put("updated_at", (String) jsonObject.get("updated_at"));
					repo_info.put("user_github_url", (String) github_id);
					repo_info.put("repo_rank_id", null);
					repo_info.put("issue_count", issue_cnt); repo_info.put("pr_count", pulls_cnt); repo_info.put("commit_count", commit_cnt);
					HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
					res = convert_insert_format(repo_info);
					String sql = String.format("INSERT INTO repository values(%d, %s, %s, %d, %d, %d, %d, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), %s, %d)", 
							res.get("repository_id"), res.get("repo_name"), res.get("repo_url"), res.get("fork_count"), res.get("stargazers_count"),
							res.get("issue_count"), res.get("pr_count"), res.get("commit_count"),
							res.get("created_at"), res.get("updated_at"), res.get("user_github_url"), res.get("ghchart_url"));
					stmt.addBatch(sql);
					repo_id ++;
				}
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			try {
				int[] count = stmt.executeBatch();
	//			if (count.length != 0) {
	//				System.out.println("repo insert Success!: "+count[0]);
	//			}
	//			else {
	//				System.out.println("repo insert Success!: 0");
	//			}
				conn.commit();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	
		static long get_codeline_count(String full_name, String sha) {
			long codeline_count = 0;
			try {
				URL url = new URL("https://api.github.com/repos/" + full_name + "/commits/" + sha);
				HttpURLConnection httpConn;
				httpConn = (HttpURLConnection)url.openConnection();
				httpConn.setRequestMethod("GET");
				
				httpConn.setRequestProperty("Accept", "application/vnd.github+json");
				httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
				
				InputStream responseStream = httpConn.getResponseCode() / 100 == 2
						? httpConn.getInputStream()
						: httpConn.getErrorStream();
				Scanner s = new Scanner(responseStream).useDelimiter("\\A");
				String response = s.hasNext() ? s.next() : "";
				JSONObject jsonObject = (JSONObject) get_json_obj(response);
				JSONObject statsObject = (JSONObject) jsonObject.get("stats");
				codeline_count = (long) statsObject.get("total");
			} catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			return codeline_count;
		}
	
		static void insert_commit_info(String github_id) {		
			String select_sql = "select max(commit_id) from commits";
			int commit_id = 0;
			try {
				ResultSet rs = stmt.executeQuery(select_sql);
				rs.next();
				String commit_id_str = rs.getString(1);
				commit_id = Integer.parseInt(commit_id_str);
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
			for (int i = 0; i < commits_url_list.size(); i++) {
				try {
					String[] full_name = ((String)commits_url_list.get(i)[0]).split("/");
					URL url = new URL(commits_url_list.get(i)[0] + "?author="+github_id);
					HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
					httpConn.setRequestMethod("GET");
					
					httpConn.setRequestProperty("Accept", "application/vnd.github+json");
					httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
					
					InputStream responseStream = httpConn.getResponseCode() / 100 == 2
							? httpConn.getInputStream()
							: httpConn.getErrorStream();
					Scanner s = new Scanner(responseStream).useDelimiter("\\A");
					String response = s.hasNext() ? s.next() : "";
					if (response.trim().charAt(0) == '[') {
						JSONArray jsonArray = (JSONArray) get_json_array_obj(response);
						for (int j = 0; j < jsonArray.size(); j++) {
							JSONObject jsonObject = (JSONObject) jsonArray.get(j);
							JSONObject commitObject = (JSONObject) jsonObject.get("commit");
							JSONObject dateObject = (JSONObject) commitObject.get("author");
							long codeline = get_codeline_count(full_name[4] + "/" + full_name[5], (String) jsonObject.get("sha"));
							HashMap<String,Object> repo_info = new HashMap<String,Object>();//HashMap생성
							String commit_msg = ((String) commitObject.get("message")).replaceAll("[\n\r\t]", "\"").replaceAll("[']", "\"").trim();
							if (commit_msg.length() >= 480) {
							commit_msg = commit_msg.substring(0, 480);
							}
							repo_info.put("commit_id", commit_id + 1); repo_info.put("commit_msg", commit_msg);
							repo_info.put("author", github_id);
							repo_info.put("commit_date", (String) dateObject.get("date"));
							repo_info.put("commit_url", (String) jsonObject.get("html_url"));
							repo_info.put("codeline_count", codeline);
							repo_info.put("repository_id", commits_url_list.get(i)[1]);
							HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
							res = convert_insert_format(repo_info);
							String sql = String.format("INSERT INTO commits values(%d, %s, %s, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), %s, %d, %d)", 
									res.get("commit_id"), res.get("commit_msg"), res.get("author"), res.get("commit_date"), 
									res.get("commit_url"), res.get("codeline_count"), res.get("repository_id"));
							stmt.addBatch(sql);
							commit_id++;
						}
					}
					
				} 
				catch (MalformedURLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			
			try {
				int[] count = stmt.executeBatch();
				conn.commit();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	
		static long get_org_star_count(String repos_url) {
			long star_count = 0;
			try {
				URL url = new URL(repos_url);
				HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
				httpConn.setRequestMethod("GET");
				
				httpConn.setRequestProperty("Accept", "application/vnd.github+json");
				httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
				
				InputStream responseStream = httpConn.getResponseCode() / 100 == 2
						? httpConn.getInputStream()
						: httpConn.getErrorStream();
				Scanner s = new Scanner(responseStream).useDelimiter("\\A");
				String response = s.hasNext() ? s.next() : "";
				if (response.trim().charAt(0) == '[') {
					JSONArray jsonArray = (JSONArray) get_json_array_obj(response);
					for (int j = 0; j < jsonArray.size(); j++) {
						JSONObject jsonObject = (JSONObject) jsonArray.get(j);
						star_count += (long) jsonObject.get("stargazers_count");
					}
					
				}
			} 
			catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	
			return star_count;
		}
	
		static HashMap<String, Object> get_org_info(String org_url) throws IOException {
			long followers = 0;
			String created_at = null, updated_at = null;
			HashMap<String,Object> org_detail_info = new HashMap<String,Object>();//HashMap생성
			URL url = new URL(org_url);
			HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
			httpConn.setRequestMethod("GET");
			
			httpConn.setRequestProperty("Accept", "application/vnd.github+json");
			httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
			
			InputStream responseStream = httpConn.getResponseCode() / 100 == 2
					? httpConn.getInputStream()
					: httpConn.getErrorStream();
			Scanner s = new Scanner(responseStream).useDelimiter("\\A");
			String response = s.hasNext() ? s.next() : "";
			JSONObject jsonObject = (JSONObject) get_json_obj(response);
			org_detail_info.put("followers", (long) jsonObject.get("followers"));
			org_detail_info.put("html_url", (String) jsonObject.get("html_url"));
			org_detail_info.put("created_at", (String) jsonObject.get("created_at"));
			org_detail_info.put("updated_at", (String) jsonObject.get("updated_at"));
			return org_detail_info;
		}
	
		static void insert_organization_info(String github_id) {
			String select_sql = "select max(organization_id) from organization";
			int org_id = 0;
			try {
				ResultSet rs = stmt.executeQuery(select_sql);
				rs.next();
				String org_id_str = rs.getString(1);
				org_id = Integer.parseInt(org_id_str);
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
			
			try {
				URL url = new URL("https://api.github.com/users/" + github_id + "/orgs");
				HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
				httpConn.setRequestMethod("GET");
				
				httpConn.setRequestProperty("Accept", "application/vnd.github+json");
				httpConn.setRequestProperty("Authorization", "Bearer " + github_token);
				
				InputStream responseStream = httpConn.getResponseCode() / 100 == 2
						? httpConn.getInputStream()
						: httpConn.getErrorStream();
				Scanner s = new Scanner(responseStream).useDelimiter("\\A");
				String response = s.hasNext() ? s.next() : "";
				if (response.trim().charAt(0) == '[') {
					JSONArray jsonArray = (JSONArray) get_json_array_obj(response);
					for (int j = 0; j < jsonArray.size(); j++) {
						JSONObject jsonObject = (JSONObject) jsonArray.get(j);
						HashMap<String,Object> org_info = new HashMap<String,Object>();//HashMap생성
						HashMap<String,Object> org_detail_info = get_org_info((String) jsonObject.get("url"));
						org_info.put("organization_id", org_id + 1); 
						org_info.put("org_name", (String) jsonObject.get("login"));
						org_info.put("avatar_url", (String) jsonObject.get("avatar_url"));
						org_info.put("org_url", (String) org_detail_info.get("html_url"));
						org_info.put("stargazers_count", get_org_star_count((String) jsonObject.get("repos_url")));
						org_info.put("followers_count", (long) org_detail_info.get("followers"));
						org_info.put("created_at", (String) org_detail_info.get("created_at"));
						org_info.put("updated_at", (String) org_detail_info.get("updated_at"));
						org_info.put("org_rank_id", null);
						HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
						res = convert_insert_format(org_info);
						sql = String.format("INSERT INTO organization values(%d, %s, %s, %s, %d, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), %d)", 
								res.get("organization_id"), res.get("org_name"), res.get("avatar_url"), res.get("org_url"), 
								res.get("stargazers_count"), res.get("followers_count"), res.get("created_at"), res.get("updated_at"), res.get("org_rank_id"));
						stmt.addBatch(sql);
						sql = String.format("INSERT INTO belong values(%s, %d)", 
								"'" + github_id + "'", res.get("organization_id"));
						stmt.addBatch(sql);
						org_id++;
					}
					conn.commit();
				}
				
			} 
			catch (MalformedURLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			
			try {
				int[] count = stmt.executeBatch();
				conn.commit();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		static void insert_user_rank_info(String github_id) {
			//기존에 존재하던 rank 삭제 
			try {
				sql = "delete from user_ranks\r\n"
						+ "where github_id = '"+github_id+"'";
				int res = stmt.executeUpdate(sql);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String githubID = "'" + github_id + "'";
			sql = "select max(user_rank_id) from user_ranks";
			int user_rank_id = 0;
			try {
				ResultSet rs = stmt.executeQuery(sql);
				rs.next();
				String user_rank_id_str = rs.getString(1);
				user_rank_id = Integer.parseInt(user_rank_id_str);
				rs.close();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			try {
				String location = null, github_url = null, created_at = null, updated_at = null;
				int followers = 0, stargazers_count = 0, codeline_count = 0, commit_count = 0;
				sql = "select location, User_github_url, followers, created_at, updated_at from member where github_id=" + githubID;
				ResultSet rs = stmt.executeQuery(sql);
				while(rs.next()) {
					// no impedance mismatch in JDBC
					location = rs.getString(1);
					github_url = rs.getString(2);
					followers = rs.getInt(3);
					created_at = rs.getString(4);
					updated_at = rs.getString(5);
				}
				
				sql = "select sum(stargazers_count), sum(commit_count), sum(codeline_count)\r\n"
						+ "from repository r join commits c on r.repository_id = c.repository_id\r\n"
						+ "where r.mgithub_id=" + githubID;
				rs = stmt.executeQuery(sql);
				while(rs.next()) {
					// no impedance mismatch in JDBC
					stargazers_count = rs.getInt(1);
					codeline_count = rs.getInt(2);
					commit_count = rs.getInt(3);
				}
				Double total_score = followers * 0.2 + codeline_count * 0.2 + stargazers_count*0.2 + commit_count*0.2;
				HashMap<String,Object> user_rank_info = new HashMap<String,Object>();//HashMap생성
				user_rank_info.put("user_rank_id", user_rank_id + 1);
				user_rank_info.put("location", location);
				user_rank_info.put("github_url", github_url);
				user_rank_info.put("stargazers_count", stargazers_count);
				user_rank_info.put("codeline_count", codeline_count);
				user_rank_info.put("followers_count", followers);
				user_rank_info.put("commit_count", commit_count);
				user_rank_info.put("total_score", total_score);
				user_rank_info.put("rank", user_rank_id + 1);
				user_rank_info.put("created_at", created_at); 
				user_rank_info.put("updated_at", updated_at);
				HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
				res = convert_insert_format(user_rank_info);
				sql = String.format("INSERT INTO user_ranks values(%d, %s, %s, %s, %d, %d, %d, %d, %.2f, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
						res.get("user_rank_id"), githubID, res.get("location"), res.get("github_url"), 
						res.get("stargazers_count"), res.get("codeline_count"), res.get("followers_count"),
						res.get("commit_count"), res.get("total_score"), res.get("rank"), res.get("created_at"), res.get("updated_at"));
				rs = stmt.executeQuery(sql);
				
				// user_rank 순위 update
				sql = "create table tmp as\r\n"
						+ "select User_rank_id, Github_id, Location, Github_url, Stargazers_count,\r\n"
						+ "        Codeline_count, Followers_count, Commit_count, Total_score, \r\n"
						+ "        RANK() OVER (ORDER BY total_score desc) Rank, Created_at, Updated_at\r\n"
						+ "from user_ranks\r\n"
						+ "order by total_score desc";
				
				stmt.executeUpdate(sql);
				sql = "DROP TABLE user_ranks CASCADE CONSTRAINTS";
				stmt.addBatch(sql);
				sql = "ALTER TABLE tmp RENAME TO user_ranks";
				stmt.addBatch(sql);
				sql = "ALTER TABLE user_ranks ADD PRIMARY KEY (User_rank_id)";
				stmt.addBatch(sql);
				sql = "ALTER TABLE user_ranks ADD UNIQUE (Github_id)";
				stmt.addBatch(sql);
				sql = "alter table member add CONSTRAINT FK_RANK foreign key (User_rank_id) references user_ranks (User_rank_id)  ON DELETE SET NULL";
				stmt.addBatch(sql);
	
				stmt.executeBatch();
				conn.commit();
				rs.close();
			}catch(SQLException ex2) {
				//System.err.println("sql error = " + ex2.getMessage());
				//System.exit(1);
			}
		}
	
		static void insert_repo_rank_info(String github_id) {
			String githubID = "'" + github_id + "'";
			sql = "select max(repo_rank_id) from repository_ranks";
			int repo_rank_id = 0;
			try {
				ResultSet rs = stmt.executeQuery(sql);
				rs.next();
				String repo_rank_id_str = rs.getString(1);
				repo_rank_id = Integer.parseInt(repo_rank_id_str);
				rs.close();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
	
			try {
				String full_name = null, repo_url = null, created_at = null, updated_at = null;
				int issue_count = 0, stargazers_count = 0, pr_count = 0, fork_count = 0, commit_count = 0;
				sql = "select Repo_name, Repo_url, Fork_count, Stargazers_count,\r\n"
						+ "        Pr_count, Issue_count, Commit_count, Created_at, Updated_at\r\n"
						+ "from repository where Mgithub_id = " + githubID;
				ResultSet rs = stmt.executeQuery(sql);
				while(rs.next()) {
					// no impedance mismatch in JDBC
					full_name = github_id + "/" + rs.getString(1);
					// 기존에 존재하던 rank 삭제
					sql = "delete from repository_ranks\n"
							+ "where full_name = '"+full_name+"'";
					stmt.addBatch(sql);
					repo_url = rs.getString(2);
					fork_count = rs.getInt(3);
					stargazers_count = rs.getInt(4);
					pr_count = rs.getInt(5);
					issue_count = rs.getInt(6);
					commit_count = rs.getInt(7);
					created_at = rs.getString(8);
					updated_at = rs.getString(9);
					Double total_score = stargazers_count * 0.15 + issue_count * 0.15 + pr_count*0.25 + fork_count*0.1 + commit_count*0.35;
					
					HashMap<String,Object> repo_rank_info = new HashMap<String,Object>();//HashMap생성
					repo_rank_info.put("repo_rank_id", repo_rank_id + 1);
					repo_rank_info.put("full_name", full_name);
					repo_rank_info.put("repo_url", repo_url);
					repo_rank_info.put("fork_count", fork_count);
					repo_rank_info.put("stargazers_count", stargazers_count);
					repo_rank_info.put("pr_count", pr_count);
					repo_rank_info.put("issue_count", issue_count);
					repo_rank_info.put("commit_count", commit_count);
					repo_rank_info.put("rank", repo_rank_id + 1);
					repo_rank_info.put("total_score", total_score);
					repo_rank_info.put("created_at", created_at); 
					repo_rank_info.put("updated_at", updated_at);
					HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
					res = convert_insert_format(repo_rank_info);
					sql = String.format("INSERT INTO repository_ranks values(%d, %s, %s, %d, %d, %d, %d, %d, %d, %.2f, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
							res.get("repo_rank_id"), res.get("full_name"), res.get("repo_url"), 
							res.get("stargazers_count"), res.get("issue_count"), res.get("pr_count"),
							res.get("fork_count"), res.get("commit_count"), res.get("rank"), res.get("total_score"), res.get("created_at"), res.get("updated_at"));
					stmt.addBatch(sql);
					repo_rank_id++;
				}
				stmt.executeBatch();
				// repo_rank 순위 update
				sql = "create table tmp as\r\n"
						+ "select Repo_rank_id, Full_name, Repo_url, Stargazers_count, Issue_count,\r\n"
						+ "        Pr_count, Fork_count, Commit_count, \r\n"
						+ "        RANK() OVER (ORDER BY total_score desc) Rank, Total_score, Created_at, Updated_at\r\n"
						+ "from repository_ranks\r\n"
						+ "order by total_score desc";
				
				stmt.executeUpdate(sql);
				sql = "DROP TABLE repository_ranks CASCADE CONSTRAINTS";
				stmt.addBatch(sql);
				sql = "ALTER TABLE tmp RENAME TO repository_ranks";
				stmt.addBatch(sql);
				sql = "ALTER TABLE repository_ranks ADD PRIMARY KEY (Repo_rank_id)";
				stmt.addBatch(sql);
				sql = "alter table repository add foreign key (Repo_rank_id) references repository_ranks (Repo_rank_id) ON DELETE SET NULL";
				stmt.addBatch(sql);
	
				stmt.executeBatch();
				conn.commit();
				rs.close();
			}catch(SQLException ex2) {
				//System.err.println("sql error = " + ex2.getMessage());
				//System.exit(1);
			}
		}
	
		static void insert_org_rank_info(String github_id) {
			String githubID = "'" + github_id + "'";
			sql = "select max(org_rank_id) from organization_ranks";
			int org_rank_id = 0;
			try {
				ResultSet rs = stmt.executeQuery(sql);
				rs.next();
				String org_rank_id_str = rs.getString(1);
				org_rank_id = Integer.parseInt(org_rank_id_str);
				rs.close();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
	
			try {
				String org_name = null, created_at = null, updated_at = null;
				int stargazers_count = 0, followers_count = 0;
				sql = "select o.org_name, o.stargazers_count, o.followers_count, o.created_at, o.updated_at\r\n"
						+ "from organization o join belong b on o.org_rank_id = b.org_id and b.mgithub_id = " + githubID;
				ResultSet rs = stmt.executeQuery(sql);
				while(rs.next()) {
					// no impedance mismatch in JDBC
					org_name = rs.getString(1);
					// 기존에 존재하던 rank 삭제
					sql = "delete from organization_ranks\n"
							+ "where org_name = '"+org_name+"'";
					stmt.addBatch(sql);
					stargazers_count = rs.getInt(2);
					followers_count = rs.getInt(3);
					created_at = rs.getString(4);
					updated_at = rs.getString(5);
					int total_score = stargazers_count + followers_count;
					
					HashMap<String,Object> org_rank_info = new HashMap<String,Object>();//HashMap생성
					org_rank_info.put("org_rank_id", org_rank_id + 1);
					org_rank_info.put("org_name", org_name);
					org_rank_info.put("stargazers_count", stargazers_count);
					org_rank_info.put("followers_count", followers_count);
					org_rank_info.put("total_score", total_score);
					org_rank_info.put("rank", org_rank_id + 1);
					org_rank_info.put("created_at", created_at); 
					org_rank_info.put("updated_at", updated_at);
					HashMap<String,Object> res = new HashMap<String,Object>();//HashMap생성
					res = convert_insert_format(org_rank_info);
					sql = String.format("INSERT INTO repository_ranks values(%d, %s, %d, %d, %d, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
							res.get("org_rank_id"), res.get("org_name"), res.get("stargazers_count"), 
							res.get("followers_count"), res.get("total_score"), res.get("rank"),
							res.get("created_at"), res.get("updated_at"));
					stmt.addBatch(sql);
					org_rank_id++;
				}
				stmt.executeBatch();
				// repo_rank 순위 update
				sql = "create table tmp as\r\n"
						+ "select distinct Org_rank_id, Org_name, Stargazers_count, Followers_count, Total_score,\r\n"
						+ "        RANK() OVER (ORDER BY total_score desc) Rank, Created_at, Updated_at\r\n"
						+ "from organization_ranks\r\n"
						+ "order by Total_score desc";
				
				stmt.executeUpdate(sql);
				sql = "DROP TABLE organization_ranks CASCADE CONSTRAINTS";
				stmt.addBatch(sql);
				sql = "ALTER TABLE tmp RENAME TO organization_ranks";
				stmt.addBatch(sql);
				sql = "ALTER TABLE organization_ranks ADD PRIMARY KEY (Org_rank_id)";
				stmt.addBatch(sql);
				sql = "alter table organization add foreign key (Org_rank_id) references organization_ranks (Org_rank_id)";
				stmt.addBatch(sql);
	
				stmt.executeBatch();
				conn.commit();
				rs.close();
			}catch(SQLException ex2) {
				//System.err.println("sql error = " + ex2.getMessage());
				//System.exit(1);
			}
		}

		static void load_rank(String github_id) {
			int user_rank_id = 0, repo_rank = 0, org_rank = 0;
			String githubID = "'" + github_id + "'";
			sql = "select User_rank_id from user_ranks where Github_id=" + githubID;
			try {
				ResultSet rs = stmt.executeQuery(sql);
				rs.next();
				String user_rankID_str = rs.getString(1);
				user_rank_id = Integer.parseInt(user_rankID_str);
				rs.close();
				
				sql = "update member set User_rank_id = " + user_rank_id + " where Github_id = " + githubID;
				stmt.executeQuery(sql);
				sql = "select Repo_url, Repo_rank_id from repository_ranks where Full_name like '" + github_id + "%'";
				ResultSet rs1 = stmt.executeQuery(sql);
				while (rs1.next()) {
					String repo_url = rs1.getString(1);
					int Repo_rank_id = rs1.getInt(2);
					sql = "update repository set Repo_rank_id = " + Repo_rank_id + " where Repo_url = '" + repo_url + "'";
					stmt.addBatch(sql);
				}
				stmt.executeBatch();
				
				sql = "select r.org_rank_id, r.org_name \r\n"
						+ "from organization_ranks r join organization o on r.org_name = o.org_name and o.org_rank_id is null";
				ResultSet rs2 = stmt.executeQuery(sql);
				while (rs2.next()) {
					int org_rank_id = rs2.getInt(1);
					String org_name = rs2.getString(2);
					sql = "update organization set Org_rank_id = " + org_rank_id + " where org_name = '" + org_name + "'";
					stmt.addBatch(sql);
				}
				stmt.executeBatch();
				conn.commit();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
    %>
    
    <%
	    String URL = "jdbc:oracle:thin:@localhost:1521:orcl";
		String USER_RANKINGHUB = "rankinghub";
		String USER_PASSWD = "comp322";
		
		String ID = (String)request.getParameter("ID");
		String pass = (String)request.getParameter("pass");
		out.println(ID);
		// 연결
		conn = DriverManager.getConnection(URL, USER_RANKINGHUB, USER_PASSWD);
		conn.setAutoCommit(false); // auto-commit disabled
		stmt = conn.createStatement(); // Create a statement object
		
		HashMap<String,Object> user_info = new HashMap<String,Object>();	//HashMap생성
		user_info = get_user_info(ID);
		if (user_info != null) {
			// 깃헙 내 아이디가 존재하지 않은 경우
			if (user_info.get("message") != null & user_info.get("message").equals("Not Found")) {
				out.println("깃헙 내 존재하지 않은 아이디 입니다...\n");
				response.sendRedirect("join.jsp");
			}
			sql = String.format("INSERT INTO MEMBER values(%s, %s, %s, %s, %s, %s, %s, %s, %s, %d, %s, %d, %d, %d, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
					user_info.get("github_id"), pass, user_info.get("avatar_url"), user_info.get("name"), user_info.get("company"),
					user_info.get("bio"), user_info.get("location"), user_info.get("user_github_url"), user_info.get("ghchart_url"),
					user_info.get("followers"), user_info.get("member_level"), user_info.get("exp"), user_info.get("commit_count_acc"),
					user_info.get("group_cnt"), user_info.get("user_rank_id"), user_info.get("created_at"), user_info.get("updated_at"));

			try {
				 int res = stmt.executeUpdate(sql);
				 out.println(res);
				 conn.commit();	
			}catch(Exception ex) {
				// in most cases, you'll see "table or view does not exist"
				out.println(ex.getMessage());
			}
			
			// Repo info insert
			String github_id = ((String)user_info.get("github_id")).replaceAll("[']", "");
			insert_repo_info(github_id);
			
			// Commit info insert
			insert_commit_info(github_id);
			
			// Organization insert
			insert_organization_info(github_id);
			// user_rank insert
			insert_user_rank_info(github_id);
			
			// repo_rank insert
			insert_repo_rank_info(github_id);
			
			// org_rank insert
			insert_org_rank_info(github_id);
			
			// load_rank_id
			load_rank(github_id);
			conn.close();
			
			session.setAttribute("sid", github_id); // ID를 계속 사용하기 위해 session에 넣어준다.
			
			response.sendRedirect("index-user.jsp");
		}
		else {
			out.println(); 
			out.println("이미 존재하는 회원입니다."); 
			response.sendRedirect("join.jsp");
		}
    %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

</body>
</html>