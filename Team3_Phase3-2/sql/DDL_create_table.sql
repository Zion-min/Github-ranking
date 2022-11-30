create table belong(
    Mgithub_id varchar2(39) not null,
    Org_id number not null,
    primary key (Mgithub_id, Org_id)
)

create table category(
    Category_id number not null,
    Category_name varchar2(15) not null,
    primary key (Category_id)
)

create table comments(
     Category_id number not null,
     Post_id number not null,
     Comment_id number not null,
     Is_anonymous char(1) not null,
     Content varchar2(1500) not null,
     Created_at timestamp(0) not null,
     Updated_at timestamp(0) not null,
     Mgithub_id varchar2(39) not null,
     check(is_anonymous = '0' or is_anonymous = '1'),
     primary key (Category_id, Post_id, Comment_id)
)

create table commits(
    Commit_id number not null,
    Commit_msg nvarchar2(500) not null,
    Author varchar2(39) not null,
    Commit_date timestamp(0) not null,
    Commit_url varchar2(200) not null,
    Codeline_count number not null,
    Repository_id number not null,
    primary key (Commit_id)
)

create table files(
    File_id number not null,
    Origin_name varchar2(100) not null,
    File_name varchar2(100) not null,
    File_path varchar2(200) not null,
    Reg_date timestamp(0) not null,
    Category_id number not null,
    Post_id number not null,
    primary key(File_id),
    unique(Origin_name)
)

create table challenge_group(
    Group_id number not null,
    Group_name varchar2(20) not null,
    Group_period number not null,
    Manage_github_id varchar2(39) not null,
    check(Group_period = 30 or Group_period = 50 or Group_period = 100 or Group_period = 200 or Group_period = 365),
    primary key(Group_id)
)

create table language(
    Language varchar2(25) not null,
    Repo_id number not null,
    Language_byte number not null,
    primary key(Language, Repo_id)
)

create table member
(
    Github_id varchar2(39) not null,
    Avatar_url varchar2(200) not null,
    User_name varchar2(255),
    Company varchar2(255),
    Bio varchar2(160),
    Location varchar2(255),
    User_github_url varchar2(58) not null,
    Ghchart_url varchar2(58) not null,
    Followers number not null,
    Member_level varchar2(3) not null,
    Exp number not null,
    Commit_count_acc number not null,
    Group_cnt number default 0 not null,
    User_rank_id number null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    primary key (Github_id),
    check (Group_cnt >= 0 and Group_cnt < 4)
)

create table organization_ranks(
    Org_rank_id number not null,
    Org_name varchar2(50) not null,
    Stargazers_count number not null,
    Followers_count number not null,
    Total_score number not null,
    Rank number not null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    primary key(Org_rank_id)
)

create table organization(
    Organization_id number not null,
    Org_name varchar2(50) not null,
    Avatar_url varchar2(200) not null,
    Org_url varchar2(200) not null,
    Stargazers_count number not null,
    Followers_count number not null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    Org_rank_id number null,
    primary key (Organization_id)
)

create table participate_in(
    Mgithub_id varchar2(39) not null,
    Group_id number not null,
    primary key (Mgithub_id, Group_id)
)

create table post(
    Category_id number not null,
    Post_id number not null,
    Title varchar2(200) not null,
    Content varchar2(4000) null,
    Views number not null,
    Likes number not null,
    Is_anonymous char(1) not null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    Mgithub_id varchar2(39) not null,
    check (is_anonymous = '0' or is_anonymous = '1'),
    primary key (Category_id, Post_id)
)

create table repository_ranks(
    Repo_rank_id number not null,
    Full_name varchar2(120) not null,
    Repo_url varchar2(200) not null,
    Stargazers_count number not null,
    Issue_count number not null,
    Pr_count number not null,
    Fork_count number not null,
    Commit_count number not null,
    Rank number not null,
    Total_score number not null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    primary key(Repo_rank_id)
)

create table repository(
    Repository_id number not null,
    Repo_name varchar2(100) not null,
    Repo_url varchar2(200) not null,
    Fork_count number not null,
    Stargazers_count number not null,
    Pr_count number not null,
    Issue_count number not null,
    Commit_count number not null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    Mgithub_id varchar2(39) not null,
    Repo_rank_id number null,
    primary key (Repository_id)
)

create table user_ranks(
    User_rank_id number not null,
    Github_id varchar2(39) not null,
    Location varchar2(26),
    Github_url varchar2(200) not null,
    Stargazers_count number not null,
    Codeline_count number not null,
    Followers_count number not null,
    Commit_count number not null,
    Total_score number not null,
    Rank number not null,
    Created_at timestamp(0) not null,
    Updated_at timestamp(0) not null,
    primary key(User_rank_id),
    unique(Github_id)
)

