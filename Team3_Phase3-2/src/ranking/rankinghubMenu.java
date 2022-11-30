package ranking;

import java.sql.*; // import JDBC package
import java.util.*;
import java.text.SimpleDateFormat;
import java.io.*;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class rankinghubMenu {
	public static Connection conn = null; // Connection object
	public static Statement stmt = null;	// Statement object
    public static String sql = ""; // an SQL statement 
    public static ArrayList<Object[]> commits_url_list = new ArrayList<Object[]>();
    
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
	
	
	static HashMap<String,Object> get_user_info() {
		Scanner sc = new Scanner(System.in);
		ResultSet rs = null;
		String github_id;
		System.out.print("깃헙 아이디를 입력하세요.>> ");
		github_id = sc.nextLine();
		
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
				httpConn.setRequestProperty("Authorization", "Bearer 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");
				
				InputStream responseStream = httpConn.getResponseCode() / 100 == 2
						? httpConn.getInputStream()
						: httpConn.getErrorStream();
				Scanner s = new Scanner(responseStream).useDelimiter("\\A");
				String response = s.hasNext() ? s.next() : "";
				JSONObject jsonObj = (JSONObject) get_json_obj(response);
				HashMap<String,Object> user_info = new HashMap<String,Object>();	//HashMap생성
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
			System.err.println("sql error = " + ex2.getMessage());
			System.exit(1);
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
			httpConn.setRequestProperty("Authorization", "Bearer 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");
			
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
			System.out.println(e1);
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
//			System.out.println(repo_id);
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		try {
			URL url= new URL("https://api.github.com/users/" + github_id + "/repos");
			HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();
			httpConn.setRequestMethod("GET");
			
			httpConn.setRequestProperty("Accept", "application/vnd.github+json");
			httpConn.setRequestProperty("Authorization", "Bearer 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");
			
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
//				System.out.println(sql);
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
			httpConn.setRequestProperty("Authorization", "Bearer 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");
			
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
//		Date date = new Date(0);
//		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
//		Calendar cal = Calendar.getInstance();
//		cal.setTime(date);
		
		String select_sql = "select max(commit_id) from commits";
		int commit_id = 0;
		try {
			ResultSet rs = stmt.executeQuery(select_sql);
			rs.next();
			String commit_id_str = rs.getString(1);
			commit_id = Integer.parseInt(commit_id_str);
//			System.out.println(commit_id);
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
				httpConn.setRequestProperty("Authorization", "Bearer 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");
				
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
//						System.out.println(sql);
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
//			if (count.length != 0) {
//				System.out.println("commit insert Success!: "+count[0]);
//			}
//			else {
//				System.out.println("commit insert Success!: 0");
//			}
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
			httpConn.setRequestProperty("Authorization", "Bearer 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");
			
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
		httpConn.setRequestProperty("Authorization", "Bearer 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");
		
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
			httpConn.setRequestProperty("Authorization", "Bearer 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");
			
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
//					System.out.println(sql);
					stmt.addBatch(sql);
					sql = String.format("INSERT INTO belong values(%s, %d)", 
							"'" + github_id + "'", res.get("organization_id"));
//					System.out.println(sql);
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
//			if (count.length != 0) {
//				System.out.println("organization insert Success!: "+count[0]);
//			}
//			else {
//				System.out.println("organization insert Success!: 0");
//			}
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
//			System.err.println("Rank Update 완료!!");
			conn.commit();
			rs.close();
		}catch(SQLException ex2) {
			System.err.println("sql error = " + ex2.getMessage());
			System.exit(1);
		}
	}
	// 추가
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
//			System.err.println("Rank Update 완료!!");
			conn.commit();
			rs.close();
		}catch(SQLException ex2) {
			System.err.println("sql error = " + ex2.getMessage());
			System.exit(1);
		}
	}
	// 추가
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
//			System.err.println("Org Rank insert 완료!!");
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
//			System.err.println("Org Rank Update 완료!!");
			conn.commit();
			rs.close();
		}catch(SQLException ex2) {
			System.err.println("sql error = " + ex2.getMessage());
			System.exit(1);
		}
	}
	// 추가
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
//			System.out.println("load 완료");
			conn.commit();
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}

	public static final String URL = "jdbc:oracle:thin:@localhost:1521:orcl";
	public static final String USER_RANKINGHUB = "gitrank";
	public static final String USER_PASSWD = "gitrank";

	public static void main(String[] args) {
			
		try {
			// Load a JDBC driver for Oracle DBMS
			Class.forName("oracle.jdbc.driver.OracleDriver");
			// Get a Connection object
			System.out.println("Driver Loading: Success!");
		} catch (ClassNotFoundException e) {
			System.err.println("error = " + e.getMessage());
			System.exit(1);
		}

		// Make a connection
		try {
			conn = DriverManager.getConnection(URL, USER_RANKINGHUB, USER_PASSWD);
			System.out.println("Oracle Connected.");
			
		} catch (SQLException ex) {
			ex.printStackTrace();
			System.err.println("Cannot get a connection: " + ex.getLocalizedMessage());
			System.err.println("Cannot get a connection: " + ex.getMessage());
			System.exit(1);
		}
		
		try {
			conn.setAutoCommit(false); // auto-commit disabled
			stmt = conn.createStatement(); // Create a statement object
		} catch (SQLException ex) {
			System.err.println("Cannot create a statement object: " + ex.getMessage());
			System.exit(1);
		} 
		
		System.out.println();
		
		// 초기콘솔창
		ResultSet rs = null;
		int log_in = 0; // 로그인 여부. 0: 로그인 안함. 1: 로그인함.
		int selectMenu1 = 0;
		int selectMenu2 = 0;
		String userID = null;
		Scanner sc = new Scanner(System.in);
		
		while (true) {
			try {
				if (log_in == 0) { // 로그인 안 한 경우의 메인 화면
					System.out.println("############# MAIN #############");
					System.out.println("1.로그인 2.회원가입 3.쿼리문실행 4.랭킹보기 5.종료");
					System.out.print("메뉴를 선택하세요. [1, 2, 3, 4, 5] >> ");
					selectMenu1 = Integer.parseInt(sc.nextLine());
					selectMenu2 = 0;
					System.out.println();
				}
				else { // 로그인 한 경우의 메인 화면
					System.out.println("############# MAIN #############");
					System.out.println("1.로그아웃 2.회원탈퇴 3.쿼리문실행 4.랭킹보기 5.프로필보기 6.내그룹정보 7.종료");
					System.out.print("메뉴를 선택하세요. [1, 2, 3, 4, 5, 6, 7] >> ");
					selectMenu2 = Integer.parseInt(sc.nextLine());
					selectMenu1 = 0;
					System.out.println();
				}
				
			
				if (selectMenu1 == 5 || selectMenu2 == 7){ // 시스템 종료
					System.out.println("시스템을 종료합니다...");
					System.out.println();
					break;
				}
				else if (selectMenu1 == 2){ // 회원가입
					System.out.println("############# SIGN UP #############");
					HashMap<String,Object> user_info = new HashMap<String,Object>();	//HashMap생성
					user_info = get_user_info();
					if (user_info != null) {
						// 깃헙 내 아이디가 존재하지 않은 경우
						if (user_info.get("message") != null) {
							System.out.println("깃헙 내 존재하지 않은 아이디 입니다...\n");
							System.out.println("MAIN 으로 이동합니다.\n");
							continue;
						}
						sql = String.format("INSERT INTO MEMBER values(%s, %s, %s, %s, %s, %s, %s, %s, %d, %s, %d, %d, %d, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
								user_info.get("github_id"), user_info.get("avatar_url"), user_info.get("name"), user_info.get("company"),
								user_info.get("bio"), user_info.get("location"), user_info.get("user_github_url"), user_info.get("ghchart_url"),
								user_info.get("followers"), user_info.get("member_level"), user_info.get("exp"), user_info.get("commit_count_acc"),
								user_info.get("group_cnt"), user_info.get("user_rank_id"), user_info.get("created_at"), user_info.get("updated_at"));
//						System.out.println(sql);
						try {
							 int res = stmt.executeUpdate(sql); 
							 conn.commit();	
						}catch(Exception ex) {
							// in most cases, you'll see "table or view does not exist"
							System.out.println(ex.getMessage());
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
						
						System.out.println(); 
						System.out.println(github_id + " 님, 회원가입이 완료되었습니다."); 
					}
					else {
						System.out.println(); 
						System.out.println("이미 존재하는 회원입니다."); 
					}
					System.out.println();
					System.out.println("메인 화면으로 돌아갑니다.");
					System.out.println();
					
				}
				else if (selectMenu1 == 1) { // 로그인
					System.out.println("############# LOGIN #############");
					System.out.print("Github ID를 입력하세요.>> ");
					userID = sc.nextLine();
					System.out.println();
					
					try {
//						sql = "select M.github_id, M.avatar_url, M.user_github_url, M.ghchart_url, U.rank, U.total_score, U.stargazers_count, U.codeline_count, U.followers_count, U.commit_count, M.member_level, M.exp "
//								+ "from member M, user_ranks U "
//								+ "where M.github_id = '" + userID + "' "
//								+ "and U.user_rank_id = M.user_rank_id";
						sql = "select M.github_id, M.avatar_url, M.user_github_url, M.ghchart_url "
								+ "from member M "
								+ "where M.github_id = '" + userID + "'";
						rs = stmt.executeQuery(sql);
						if (!rs.isBeforeFirst()) { // 회원정보 없으면
							System.out.println("유효한 회원 정보가 없습니다.");
						}
						else { // 회원정보 있으면
							System.out.printf("** 반갑습니다. '%s' 님 **%n", userID);
							log_in = 1; // 로그인 됨.
						}
						rs.close();
						System.out.println();
						System.out.println("메인 화면으로 돌아갑니다.");
						System.out.println();
					} catch (SQLException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}	
				else if (selectMenu2 == 1) { // 로그아웃
					log_in = 0;
					userID = null;
					System.out.println("로그아웃되었습니다.");
					System.out.println("메인 화면으로 돌아갑니다.");
					System.out.println();
				}
				else if (selectMenu2 == 2 && userID!=null) { // 회원탈퇴
					while (true) {
						System.out.printf("%s 님, 정말 탈퇴하시겠습니까?[Y/N]>> ", userID);
						String answer = sc.nextLine();
						System.out.println();
						if (answer.equals("Y")) { // 회원탈퇴 Yes
							ArrayList<Integer> gidList = new ArrayList<>();
							ArrayList<String> nameList = new ArrayList<>();
							

							// 그룹매니저로 있는 그룹아이디 체크
							try {
								sql = "select g.group_id, g.group_name\n"
										+"from challenge_group g, participate_in p\n"
										+"where g.group_id = p.group_id and g.manage_github_id = p.mgithub_id and g.manage_github_id = '"+userID+"'";
								rs = stmt.executeQuery(sql);
								while (rs.next()) {
									int groupID = rs.getInt(1);
									String groupName = rs.getString(2);
									System.out.printf("관리 그룹 : %s\n", groupName);
									gidList.add(groupID);
									nameList.add(groupName);
								}
								rs.close();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							
							// 그룹 없애기 전에 그룹 매니저 양도 여부 확인
							for(int i=0; i< gidList.size(); i++)
							{
								try {
									sql = "select mgithub_id\n"
											+"from (select *\n"
													+"from participate_in\n"
													+"where group_id ="+gidList.get(i)+" and mgithub_id != '"+ userID +"')\n"
													+"where rownum = 1";
									rs = stmt.executeQuery(sql);
									rs.next();
									String newManagerCandidate= rs.getString(1);
									while(true)
									{
										System.out.printf("그룹 %s의 매니저를 '%s'회원에게 양도합니다. 동의하겠습니까? [Y/N] >> ", nameList.get(i), newManagerCandidate);
										String an = sc.nextLine();
										if (an.equals("Y"))
										{
											sql = "update challenge_group\n"
													+"set manage_github_id = '"+newManagerCandidate+"'\n"
													+"where group_id = "+gidList.get(i);
											int res = stmt.executeUpdate(sql);
											if(res>0) {
												System.out.println("성공적으로 양도되었습니다.");
											} else {
												System.out.println("양도에 실패하였습니다.");
											}
											break;
										}
										else if (an.equals("N")) { //  회원탈퇴 취소
											System.out.println("취소되었습니다.");
											break;
										}
										else {
											System.out.println("잘못된 입력입니다. 다시 입력해주십시오.");
										}	
									}
									rs.close();
								}	
								catch (SQLException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
							}
							
							// 차례대로 없애기 
							try {
								sql = "delete comments\n"
										+"where mgithub_id = '"+userID+"'";
								stmt.addBatch(sql);
								
								sql = "delete from files f\n"
										+ "where exists(select * "
										+ "from post p\n"
										+ "where p.post_id = f.post_id and p.mgithub_id = '"+userID+"')";
								stmt.addBatch(sql);
								
								sql = "delete from comments c\n"
										+"where exists(\n"
										+"select * from post p \n"
										+ "where p.post_id = c.post_id and p.mgithub_id = '"+userID+"')";
								stmt.addBatch(sql);
								

								sql = "delete post\n"
									+"where mgithub_id = '"+userID+"'";
								stmt.addBatch(sql);
								
								sql = "delete from commits c\n"
								+"where exists(\n"
								+"select *\n"
								+"from repository r, member m\n"
								+"where r.mgithub_id = m.github_id and r.repository_id = c.repository_id and m.github_id = '"+userID+"')";
								stmt.addBatch(sql);
								
								sql = "delete from language l\n"
								+"where exists(\n"
								+"select *\n"
								+"from repository r, member m\n"
								+ "where r.mgithub_id = m.github_id and m.github_id = '"+userID+"' and r.repository_id = l.repo_id)";
								stmt.addBatch(sql);
								
								sql = "delete from repository\n" 
								+"where mgithub_id = '"+userID+"'";
								stmt.addBatch(sql);
								
								sql = "delete from participate_in\n"
								+"where mgithub_id = '"+userID+"'";
								stmt.addBatch(sql);
								
								sql = "delete from belong\n"
								+"where mgithub_id = '"+userID+"'";
								stmt.addBatch(sql);
								
								sql = "delete from participate_in p\n"
								+ "where exists\n"
								+ "(select *\n"
								+"from challenge_group g\n"
								+"where g.manage_github_id = '"+userID+"' and p.group_id = g.group_id)";
								stmt.addBatch(sql);
								
								sql = "delete from challenge_group\n"
								+"where manage_github_id = '"+userID+"'";
								stmt.addBatch(sql);
								
								sql = "delete from member\n"
								+"where github_id = '"+userID+"'";
								stmt.addBatch(sql);
								
					            int[] count = stmt.executeBatch();
					            System.out.println("탈퇴가 완료되었습니다.");
								
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							try{
								conn.commit();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							log_in = 0;
							break;
						}
						else if (answer.equals("N")) { //  회원탈퇴 취소
							System.out.println("취소되었습니다.");
							break;
						}
						else {
							System.out.println("잘못된 입력입니다. 다시 입력해주십시오.");
						}	
						
					}
					System.out.println();
					System.out.println("메인 화면으로 돌아갑니다.");
					System.out.println();
				}
				else if (selectMenu1 == 3 || selectMenu2 == 3) { // 쿼리 실행문
					while (true) {
						System.out.println("############# Query LIST #############");
						System.out.println("1: Commit_count_acc(연속 커밋 수)가 __일 이상인 멤버의 Github_id, Member_level, Commit_count_acc 를 보여라!\n"
								+ "2. Likes(좋아요)가 __개 이상인 POST 의 Views, Likes, Title 보여라!\n"
								+ "3. MEMBER가 소유한 Repository 중 Stargazers_count 가 __개 이상인 Repository에 해당 MEMBER가 작성한 Commit_msg(커밋 메시지)를 보여라!\n"
								+ "4. Oranization 중 Rank __위 이상에 속한 Member 의 Github_id, Ghchart_url (잔디 url), Follower 를 보여줘라!\n"
								+ "5. 파일을 __개 이상 올린 post 의  댓글 생성 시간(Created_at), comment content 을 보여라!\n"
								+ "6. User_rank Total 점수가 ____점 이상인 사람들 중 Company 를 다니고 있고 Follower 수가 __명 이상인 Member 의 Github_id, User_Github_url, Group_cnt 를 보여줘라!\n"
								+ "7. 그룹 목표 기간이 __일 이하인 그룹에 속한 멤버들 중 Github 에 이름을 등록한 사람들의 User_name, Avatar_url 을 보여라!\n"
								+ "8. ___ 언어로 작성된 Repository 를 가진 Member 의 Github_id, User_github_url 를 보여라!\n"
								+ "9. Stargazers 가 __개 이상인 Repository 의 Repo_name, Stargazers_count, Rank, Pr 개수를 보여주고, 해당 Repository 를 소유한 멤버의 Github_id, Followers 수를 보여라! (Stargazers_count 내림차순)\n"
								+ "10. 그룹 내 멤버들의 평균 커밋 수가 __개 이상인 그룹의 Group_name과 해당 그룹에 속한 멤버들의 Github_id, Rank 를 보여라!\n"
								+ "11. 쿼리실행 종료. 메인화면으로 이동합니다.");
						System.out.print("원하는 쿼리문을 선택하세요.>> ");
						
						int selectQuery = Integer.parseInt(sc.nextLine());
						System.out.println();
						if (selectQuery == 1){
							System.out.println("############# Query 1 #############");
							System.out.println("1: Commit_count_acc(연속 커밋 일수)가 __일 이상인 멤버의 Github_id, Member_level, Commit_count_acc 를 보여라!");
							System.out.print("원하는 제한조건(연속 커밋일수)을 입력하세요. >> ");
							String Commit_count_acc = sc.nextLine();
							try {
								sql = "select Github_id, Member_level, Commit_count_acc\n" + 
										 "from MEMBER\n" + 
										 "where Commit_count_acc >= " + Commit_count_acc;
								rs = stmt.executeQuery(sql);
								System.out.println("\n<< query 1 result >>");
								System.out.printf(" %-20s | %-20s | %-10s %n", "Github_id", "Member_level", "Commit_count_acc");
								System.out.println("-----------------------------------------------------------------");
								while (rs.next()) {
									String github_id = rs.getString(1);
									int member_level = rs.getInt(2);
									int commit_count_acc = rs.getInt(3);
									System.out.printf(" %-20s | %-20d | %-10d %n", github_id, member_level, commit_count_acc);	
							}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 2){
							System.out.println("############# Query 2 #############");
							System.out.println("2. Likes(좋아요)가 __개 이상인 POST 의 Views, Likes, Title 보여라!");
							System.out.print("원하는 제한조건(좋아요수)을 입력하세요. >> ");
							String likes_cnt = sc.nextLine();
							try {
								sql = "select Views, Likes, Title\n"+
										"from POST\n"+
										"where Likes >= " + likes_cnt;
								rs = stmt.executeQuery(sql);
								System.out.println("\n<< query 2 result >>");
								System.out.printf(" %-10s | %-10s |  %-60s %n", "Views", "Likes", "Title");
								System.out.println("-------------------------------------------------------------------------------------------");
								while (rs.next()) {
									int views_2 = rs.getInt(1);
									int likes_2 = rs.getInt(2);
									String title_2 = rs.getString(3);
									System.out.printf(" %-10d | %-10d |  %-60s %n", views_2, likes_2, title_2);	
							}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 3){
							System.out.println("############# Query 3 #############");
							System.out.println("3. MEMBER가 소유한 Repository 중 Stargazers_count 가 __개 이상인 Repository에 해당 MEMBER가 작성한 Commit_msg(커밋 메시지)를 보여라!");
							System.out.print("원하는 제한조건(star 수)을 입력하세요. >> ");
							String star_cnt_3 = sc.nextLine();
							try {
								sql = "select M.Github_id, R.Repo_name, C.Commit_msg\n"+
										"from MEMBER M, Repository R, COMMITS C\n"+
										"where M.Github_id = R.Mgithub_id and R.Repository_id = C.Repository_id\n" +
													"and R.Stargazers_count >= " + star_cnt_3;
								rs = stmt.executeQuery(sql);
								System.out.println("\n<< query 3 result >>");
								System.out.printf(" %-20s | %-30s | %-60s %n", "Github_id", "Repo_name", "Commit_msg");
								System.out.println("-----------------------------------------------------------------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									String github_id_3 = rs.getString(1);
									String repo_name_3 = rs.getString(2);
									String commit_msg_3 = rs.getString(3);
									System.out.printf(" %-20s | %-30s | %-60s %n", github_id_3, repo_name_3, commit_msg_3);	
							}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 4){
							System.out.println("############# Query 4 #############");
							System.out.println("4. Oranization 중 Rank __위 이상에 속한 Member 의 Github_id, Ghchart_url (잔디 url), Follower 를 보여줘라!");
							System.out.print("원하는 제한조건(organization 랭킹)을 입력하세요. >> ");
							String orgRank4 = sc.nextLine();
							try {
								sql = "select Github_id, Ghchart_url, Followers\n"+
										"from MEMBER\n"+ 
										"where Github_id in (select BL.Mgithub_id\n"+ 
										"from BELONG BL, ORGANIZATION ORG, ORGANIZATION_RANKS ORG_R\n"+
										"where BL.Org_id = ORG.Organization_id and ORG.Org_rank_id = ORG_R.Org_rank_id\n"+
										"and ORG_R.Rank <= "+ orgRank4 +")";
								rs = stmt.executeQuery(sql);
								System.out.println("\n<< query 4 result >>");
								System.out.printf(" %-20s | %-60s | %-10s %n", "Github_id", "Ghchart_url", "Followers");
								System.out.println("-------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									String gitId4 = rs.getString(1);
									String ghChart4 = rs.getString(2);
									String followers4 = rs.getString(3);
									System.out.printf(" %-20s | %-60s | %-10s %n", gitId4, ghChart4, followers4);	
							}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 5){
							System.out.println("############# Query 5 #############");
							System.out.println("5. 파일을 __개 이상 올린 post 의  댓글 생성 시간(Created_at), comment content 을 보여라!");
							System.out.print("원하는 제한조건(파일 개수)을 입력하세요. >> ");
							String files5 = sc.nextLine();
							try {
								sql = "select C.Created_at, C.Content\n"+
										"from COMMENTS C\n"+
										"where (Category_id, Post_id) in ( select C.Category_id, P.Post_id\n"+
																			"from CATEGORY C, POST P, FILES F\n"+
																			"where C.Category_id = P.Category_id  and F.Post_id = P.Post_id\n"+
																			"group by C.Category_id, P.Post_id\n"+
																			"having count(File_id) >= " + files5 +")";
								rs = stmt.executeQuery(sql);
								System.out.println("\n<< query 5 result >>");
								System.out.printf(" %-20s | %-80s %n", "Created_at", "Content");
								System.out.println("-------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									String createAt5 = rs.getString(1);
									String commContent5 = rs.getString(2);
									System.out.printf(" %-20s | %-80s %n", createAt5, commContent5);	
							}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 6){
							System.out.println("############# Query 6 #############");
							System.out.println("User_rank Total 점수가 ____점 이상인 사람들 중 Company 를 다니고 있고 Follower 수가 __명 이상인 Member 의 Github_id, User_Github_url, Group_cnt 를 보여줘라!");
							System.out.print("원하는 제한조건(User_rank Total 점수, Follower 수)을 입력하세요. 두 변수 값은 띄어쓰기로 구분합니다.>> ");
							String temp = sc.nextLine();
							String[] stChange = temp.split(" ");
							try {
								sql = "select M.Github_id, M.User_Github_url, M.Group_cnt "
										+ "from MEMBER M "
										+ "where M.Github_id in "
										+ "(select UR.Github_id "
										+ "from USER_RANKS UR "
										+ "where UR.Total_score >= " + stChange[0]+ ") "
										+ "and M.Company is not null "
										+ "and M.Followers >= " + stChange[1];
								rs = stmt.executeQuery(sql);
								System.out.println("<< query 6 result >>");
								System.out.printf(" %-20s | %-60s | %-10s %n", "Github_id", "User_Github_url", "Group_cnt");
								System.out.println("-------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									String github_id = rs.getString(1);
									String user_Github_url = rs.getString(2);
									int group_cnt = rs.getInt(3);
									System.out.printf(" %-20s | %-60s | %-10d %n", github_id, user_Github_url, group_cnt);
								}
								rs.close();
	
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 7){
							System.out.println("############# Query 7 #############");
							System.out.println("그룹 목표 기간이 __일 이하인 그룹에 속한 멤버들 중 Github 에 이름을 등록한 사람들의 User_name, Avatar_url 을 보여라!");
							System.out.print("원하는 제한조건(그룹 목표 기간:일)을 입력하세요.>> ");
							String days = sc.nextLine();
							try {
								sql = "with UnderN AS "
										+ "(select P.Mgithub_id as Github_id "
										+ "from CHALLENGE_GROUP G, PARTICIPATE_IN P "
										+ "where G.Group_id = P.Group_id and G.Group_period <= " + days + ") "
										+ "select distinct User_name, Avatar_url "
										+ "from MEMBER M, UnderN U "
										+ "where M.Github_id = U.Github_id and M.User_name is not null";
								rs = stmt.executeQuery(sql);
								System.out.println("<< query 7 result >>");
								System.out.printf(" %-25s | %-80s %n", "User_name", "Avatar_url");
								System.out.println("---------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									String name = rs.getString(1);
									String avatar_url = rs.getString(2);
									System.out.printf(" %-25s | %-80s %n", name, avatar_url);
								}
								rs.close();
	
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 8){
							System.out.println("############# Query 8 #############");
							System.out.println("___ 언어로 작성된 Repository 를 가진 Member 의 Github_id, User_github_url 를 보여라!");
							System.out.print("원하는 제한조건(프로그래밍 언어)을 입력하세요.>> ");
							String language = sc.nextLine();
							try {
								sql = "with LanguageRepo AS "
										+ "(select R.Mgithub_id as Github_id "
										+ "from REPOSITORY R, LANGUAGE L "
										+ "where R.Repository_id = L.Repo_id and L.Language = '" + language + "') "
										+ "select distinct M.Github_id, M.User_github_url "
										+ "from MEMBER M, LanguageRepo PR "
										+ "where M.Github_id = PR.Github_id";
								rs = stmt.executeQuery(sql);
								System.out.println("<< query 8 result >>");
								System.out.printf(" %-20s | %-60s %n",  "Github_id", "User_Github_url");
								System.out.println("-------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									String github_id = rs.getString(1);
									String user_Github_url = rs.getString(2);
									System.out.printf(" %-20s | %-60s %n", github_id, user_Github_url);
								}
								rs.close();
	
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 9){
							System.out.println("############# Query 9 #############");
							System.out.println("Stargazers 가 __개 이상인 Repository 의 Repo_name, Stargazers_count, Rank, Pr 개수를 보여주고, 해당 Repository 를 소유한 멤버의 Github_id, Followers 수를 보여라! (Stargazers_count 내림차순)");
							System.out.print("원하는 제한조건(Stargazers 개수)을 입력하세요.>> ");
							String stars = sc.nextLine();
							try {
								sql = "select R.Repo_name, R.Stargazers_count, RR.Rank, R.Pr_count, M.Github_id, M.Followers "
										+ "from ((REPOSITORY R join REPOSITORY_RANKS RR "
										+ "ON R.Repository_id = RR.Repo_rank_id) JOIN MEMBER M ON M.Github_id = R.Mgithub_id) "
										+ "where R.Stargazers_count >= " + stars + " "
										+ "order by R.Stargazers_count desc";
								rs = stmt.executeQuery(sql);
								System.out.println("<< query 9 result >>");
								System.out.printf(" %-40s | %-12s | %-10s | %-10s | %-20s | %-10s %n",  "Repo_name", "Stargazers_count", "Rank", "Pr_count", "Github_id", "Followers");
								System.out.println("---------------------------------------------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									String repo = rs.getString(1);
									int star = rs.getInt(2);
									int rank = rs.getInt(3);
									int pr = rs.getInt(4);
									String id = rs.getString(5);
									int follower = rs.getInt(6);
									System.out.printf(" %-40s | %-12d | %-10d | %-10d | %-20s | %-10d %n", repo, star, rank, pr, id, follower);
								}
								rs.close();
	
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 10){
							System.out.println("############# Query 10 #############");
							System.out.println("그룹 내 멤버들의 평균 커밋 수가 __개 이상인 그룹의 Group_name과 해당 그룹에 속한 멤버들의 Github_id, Rank 를 보여라!");
							System.out.print("원하는 제한조건(그룹 내 멤버들의 평균 커밋 수)을 입력하세요.>> ");
							String commits = sc.nextLine();
							try {
								sql = "select G.group_name, M.Github_id, UR.Rank, UR.Commit_count "
										+ "from (((CHALLENGE_GROUP G join PARTICIPATE_IN P on G.group_id = P.group_id) "
										+ "join MEMBER M on P.Mgithub_id = M.Github_id) "
										+ "join USER_RANKS UR on M.User_rank_id = UR.User_rank_id) "
										+ "where G.group_id in (select g.Group_id "
										+ "from challenge_group g, user_ranks ur, participate_in p "
										+ "where g.Group_id = p.Group_id and p.Mgithub_id = ur.Github_id "
										+ "group by g.group_id "
										+ "having avg(ur.Commit_count) >= " + commits + ") "
										+ "order by UR.Rank";
								rs = stmt.executeQuery(sql);
								System.out.println("<< query 10 result >>");
								System.out.printf(" %-20s | %-20s | %-10s | %-10s %n",  "Group_name", "Github_id", "Rank", "Commit_count");
								System.out.println("----------------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									String gname = rs.getString(1);
									String id = rs.getString(2);
									int rank = rs.getInt(3);
									int commit = rs.getInt(4);
									System.out.printf(" %-20s | %-20s | %-10d | %-10d %n", gname, id, rank, commit);
								}
								rs.close();
	
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (selectQuery == 11){
							System.out.println("쿼리 실행을 종료합니다...");
							System.out.println("MAIN으로 돌아갑니다.");
							System.out.println();
							break;
						}
						else {
							System.out.println("존재하지 않는 옵션입니다.");
							System.out.println("쿼리를 다시 선택해주세요.");
							System.out.println();
						}
					}
				}
				else if (selectMenu1 == 4 || selectMenu2 == 4) { // 랭킹보기
					while(true) {
						System.out.println("############# RANK MENU #############");
						System.out.println("1.User 2.Repository 3.Organization 4.메인으로 돌아가기");
						System.out.print("원하는 랭킹 정보를 선택하세요.[1, 2, 3, 4] >> ");
						int rankMenu = Integer.parseInt(sc.nextLine());
						System.out.println();
						if (rankMenu == 1) { // 유저 기준 top 10
							try {
								sql = "select rank, github_id, github_url "
										+ "from user_ranks "
										+ "where rank <= 10 "
										+ "order by rank";
								rs = stmt.executeQuery(sql);
								System.out.println("############# USER RANK TOP 10 #############");
								System.out.printf(" %-7s | %-20s | %-50s %n",  "Rank", "Github_id", "Github_URL");
								System.out.println("---------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									int userRank10 = rs.getInt(1);
									String Github_id = rs.getString(2);
									String githubUrl = rs.getString(3);
									System.out.printf(" %-7s | %-20s | %-50s %n", userRank10, Github_id, githubUrl);
								}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (rankMenu == 2) {// 레포 기준 top 10
							try {
								sql = "select rank, full_name, repo_url "
										+ "from repository_ranks "
										+ "where rank <= 10 "
										+ "order by rank";
								rs = stmt.executeQuery(sql);
								System.out.println("############# REPOSITORY RANK TOP 10 #############");
								System.out.printf(" %-7s | %-40s | %-50s %n",  "Rank", "Repo Name", "Repo URL");
								System.out.println("-----------------------------------------------------------------------------------------------------");
								while (rs.next()) {
									// Fill out your code
									int repoRank10 = rs.getInt(1);
									String repoName = rs.getString(2);
									String repoUrl = rs.getString(3);
									System.out.printf(" %-7s | %-40s | %-50s %n", repoRank10, repoName, repoUrl);
								}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (rankMenu == 3) {// 단체 기준 top 10
							try {
								sql = "select rank, org_name "
										+ "from organization_ranks "
										+ "where rank <= 10 "
										+ "order by rank";
								rs = stmt.executeQuery(sql);
								System.out.println("############# ORGANIGATION RANK TOP 10 #############");
								System.out.printf(" %-7s | %-20s %n",  "Rank", "Org Name");
								System.out.println("---------------------------------------");
								while (rs.next()) {
									// Fill out your code
									int orgRank10 = rs.getInt(1);
									String orgName = rs.getString(2);
									System.out.printf(" %-7s | %-20s %n", orgRank10, orgName);
								}
								rs.close();
								System.out.println();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						else if (rankMenu == 4) {// 메인으로 돌아가기
							System.out.println("메인 화면으로 돌아갑니다.");
							System.out.println();
							break;
						}
						else { // 없는 메뉴
							System.out.println("존재하지 않는 옵션입니다.");
							System.out.println("기준을 다시 선택해주세요.");
							System.out.println();
						}	
					}
				}
				else if (selectMenu2 == 5) { // 프로필보기
						try {
						sql = "select M.github_id, M.avatar_url, M.user_github_url, M.ghchart_url, U.rank, U.total_score, U.stargazers_count, U.codeline_count, U.followers_count, U.commit_count, M.member_level, M.exp "
								+ "from member M, user_ranks U "
								+ "where M.github_id = '" + userID + "' "
								+ "and U.user_rank_id = M.user_rank_id";
						rs = stmt.executeQuery(sql);
						System.out.println("############# USER PLOFILE #############"); // 유저 프로필 보여줌: ID, avatar URL, Github URL, chart URL, follower, level, exp, com acc, group count, rank
						rs.next();
						System.out.printf("<< '%s' Github Description >>%n", userID); // 기본 Github 정보
						System.out.printf("Github ID: %s%n", rs.getString(1));
						System.out.printf("Avatar URL: %s%n", rs.getString(2));
						System.out.printf("Github URL: %s%n", rs.getString(3));
						System.out.printf("Ghchart URL: %s%n", rs.getString(4));
						System.out.printf("<< '%s' Ranking >>%n", userID); // 랭킹 정보
						System.out.printf("Rank: %d%n", rs.getInt(5));
						System.out.printf("Total Score: %d%n", rs.getInt(6));
						System.out.printf(" - Stars: %d%n", rs.getInt(7));
						System.out.printf(" - Codelines: %d%n", rs.getInt(8));
						System.out.printf(" - Followers: %d%n", rs.getInt(9));
						System.out.printf(" - Commits: %d%n", rs.getInt(10));
						System.out.printf("<< '%s' LEVEL >>%n", userID); // 레벨 정보
						System.out.printf("Level: %d%n", rs.getInt(11));
						System.out.printf("EXP: %d%n", rs.getInt(12));
						
						rs.close();
						System.out.println();
						System.out.println("메인 화면으로 돌아갑니다.");
						System.out.println();
					} catch (SQLException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
				else if (selectMenu2 == 6) { // 그룹정보
					
						try {
							int[] groupIds = new int[3];
							int[] periods = new int[3];
							String[] groupNames = new String[3];
							String[] managers = new String[3];
							sql = "select C.group_name, C.group_period, C.manage_github_id, C.group_id "
									+ "from member M, participate_in P, challenge_group C "
									+ "where M.github_id = '" + userID + "' "
									+ "and M.github_id = P.mgithub_id "
									+ "and P.group_id = C.group_id";
							rs = stmt.executeQuery(sql);
							System.out.println("############# MY GROUP INFORMATION #############"); // 내가 속한 그룹 정보 보여줌
							System.out.println("< " + userID + " > 님의 그룹 정보입니다.");
							System.out.printf(" %-8s | %-15s | %-10s | %-20s %n", "Index", "Group Name", "Period", "Manager");
							System.out.println("---------------------------------------------------------------");
							int count = 0;
							while (rs.next()) {
								String groupName = rs.getString(1);
								int period = rs.getInt(2);
								String manager = rs.getString(3);
								int gid = rs.getInt(4);
								
								groupIds[count] = gid;
								groupNames[count] = groupName;
								periods[count] = period;
								managers[count] = manager;
								
								count ++;
								
								System.out.printf(" %-8d | %-15s | %-10s | %-20s %n", count, groupName, period, manager);
							}
							rs.close();
							System.out.println("** 총 " + count + "개의 그룹에 속해있습니다. **");
							System.out.println();
							while (true) {
								System.out.println("############# GROUP VIEWS #############");
								for (int i = 0; i < count; i++) {
									System.out.print((i+1) + "." + groupNames[i] + " ");
								}
								System.out.print((count+1) + ".메인으로 돌아가기");
								System.out.println();
								System.out.print("그룹의 상세정보를 알고싶다면 해당 그룹의 Index를 입력하세요. >> ");
								int groupMenu = Integer.parseInt(sc.nextLine());					
								
								if (groupMenu == (count+1)) { // 메인으로 돌아가기
									System.out.println();
									System.out.println("메인 화면으로 돌아갑니다.");
									System.out.println();
									break;
									
								}
								else if (groupMenu > (count+1)) { // 없는 메뉴
									System.out.println();
									System.out.println("존재하지 않는 Index 입니다.");
									System.out.println("다시 선택해주세요.");
									System.out.println();
								}
								else { // 그룹 상세정보 보기
									String nowGname = groupNames[groupMenu-1];
									String nowGmng = managers[groupMenu-1];
									int nowGp = periods[groupMenu-1];
									System.out.println();
									
									try {
										sql = "select M.github_id, M.user_github_url, M.member_level, M.exp, U.Rank "
												+ "from member M, participate_in P, challenge_group C, user_ranks U "
												+ "where C.group_id = " + (groupIds[groupMenu-1]) + " "
												+ "and M.github_id = P.mgithub_id "
												+ "and P.group_id = C.group_id "
												+ "and U.user_rank_id = M.user_rank_id "
												+ "order by U.Rank";
										rs = stmt.executeQuery(sql);
										System.out.println("############# GROUP: " + nowGname + " #############");
										System.out.println("- Manager: " + nowGmng);
										System.out.println("- Period: " + nowGp);
										System.out.println("- Member Info: ");
										System.out.printf(" %-15s | %-15s | %-40s | %-8s | %-8s %n", "Rank in Group", "Github ID", "Github URL", "Level", "Exp");
										System.out.println("-----------------------------------------------------------------------------------------------");
										int grank = 0;
										while (rs.next()) {
											// Fill out your code
											grank ++;
											String gId = rs.getString(1);
											String gUrl = rs.getString(2);
											int gLevel = rs.getInt(3);
											int gExp = rs.getInt(4);
											System.out.printf(" %-15d | %-15s | %-40s | %-8d | %-8d %n", grank, gId, gUrl, gLevel, gExp);
										}
										rs.close();
										System.out.println();
									} catch (SQLException e) {
										// TODO Auto-generated catch block
										e.printStackTrace();
									}
									
								}
							}
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();					
						}
					}
				
				else {
					selectMenu1 = 0;
					selectMenu2 = 0;
					System.out.println("존재하지 않는 메뉴입니다.");
					System.out.println("다시 선택해주세요.");
					System.out.println();
				}
			} catch (NumberFormatException formatE){
				selectMenu1 = 0;
				selectMenu2 = 0;
				System.out.println();
				System.out.println("!!ERROR!!");
				System.out.println("잘못된 형식의 입력입니다.");
				System.out.println("메인 화면으로 돌아갑니다.");
				System.out.println();
			}
		}
			
		// Release database resources.
		try {
			// Close the Statement object.
			stmt.close();
			// Close the Connection object.
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		System.out.println("종료되었습니다.");
	}

}
