alter table member add foreign key (User_rank_id) references user_ranks (User_rank_id);

alter table repository add foreign key (Mgithub_id) references member (Github_id);
alter table repository add foreign key (Repo_rank_id) references repository_ranks (Repo_rank_id);

alter table language add foreign key (Repo_id) references repository (Repository_id);

alter table commits add foreign key (Repository_id) references repository (Repository_id);

alter table organization add foreign key (Org_rank_id) references organization_ranks (Org_rank_id);

alter table challenge_group add foreign key (Manage_github_id) references member (Github_id);

alter table post add foreign key(Category_id) references category(Category_id);
alter table post add foreign key(Mgithub_id) references member(Github_id);


alter table comments add foreign key (Category_id, Post_id) references post (Category_id, Post_id);
alter table comments add foreign key (Mgithub_id) references member (Github_id);

alter table files add foreign key(Category_id, Post_id) references post(Category_id,Post_id);

alter table belong add foreign key (Mgithub_id) references member (Github_id);
alter table belong add foreign key (Org_id) references organization (Organization_id);

alter table participate_in add foreign key (Mgithub_id) references member (Github_id);
alter table participate_in add foreign key (Group_id) references challenge_group (Group_id);