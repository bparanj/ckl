# Watch the Screencast
[![ Rails 5 todo list app with jQuery and Ajax](https://d2d8g20jj5tev4.cloudfront.net/rubyplus-screencast.png)](https://rubyplus.com/episodes/101-Ajax-using-jQuery-in-Rails-5)

rails new ckl --skip-spring

```
rails g model task name complete:boolean
```

seeds.rb:

```ruby
Task.create! name: "Meet Mr. Miyagi", complete: true
Task.create! name: "Paint the fence", complete: true
Task.create! name: "Wax the car"
Task.create! name: "Sand the deck"
```

```
rails g controller tasks index new 
```

Default complete flag to false.

```ruby
class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.boolean :complete, default: false, null: false

      t.timestamps
    end
  end
end
```

```ruby
class TasksController < ApplicationController
  def index
    @incomplete_tasks = Task.where(complete: false)
    @complete_tasks = Task.where(complete: true)
  end

  def new
    @task = Task.new
  end
  
  def create
    @task = Task.create!(allowed_params)
    
    redirect_to tasks_url
  end
  
  def update
    @task = Task.find(params[:id])
    @task.update_attributes!(allowed_params)
    
    redirect_to tasks_url
  end
  
  def destroy
    @task = Task.destroy(params[:id])
    
    redirect_to tasks_url
  end
  
  private
  
  def allowed_params
    params.require(:task).permit(:name, :complete)
  end
end
```

routes.rb:

```ruby
Rails.application.routes.draw do
  resources :tasks
  
  root to: 'tasks#index'
end
```

```
rails db:migrate
rails db:seed
```

index.html.erb:

```rhtml
<h1>Task Dog</h1>
<%= link_to "New Task", new_task_path, id: "new_link" %>
<h2>Incomplete Tasks</h2>
<div class="tasks" id="incomplete_tasks">
  <%= render @incomplete_tasks %>
</div>

<h2>Comlpete Tasks</h2>
<div class="tasks" id="complete_tasks">
  <%= render @complete_tasks %>
</div>
```

task partial:

```rhtml
<%= form_for task do |f| %>
  <%= f.check_box :complete %>
  <%= f.submit "Update" %>
  <%= f.label :complete, task.name %>
  <%= link_to "(remove)", task, method: :delete, data: {confirm: "Are you sure?"} %>
<% end %>
```

new.html.erb:

```rhtml
<h1>New Task</h1>
<%= render 'form' %>
<p><%= link_to "Back to tasks", tasks_path %></p>
```

_form.html.erb:

```rhtml
<%= form_for @task do |f| %>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

Check the source code https://github.com/bparanj/ckl for css and the layout file changes.

new.js.erb:

```rhtml
$('#new_link').hide().after('<%= j render("form") %>');
```

Make the 'New Task' link render a form using ajax. Add remote: true to the form partial.

```rhtml
<%= form_for @task, remote: true do |f| %>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

and the 'New Task' link:

```rhtml
<%= link_to "New Task", new_task_path, id: "new_link", remote: true %>
```

You can create a task with the inline form. You can see that there is a redirect after the task is created.

```
Started POST "/tasks" for ::1 at 2016-07-07 16:22:50 -0700
Processing by TasksController#create as JS
  Parameters: {"utf8"=>"✓", "task"=>{"name"=>"Buy a necklace"}, "commit"=>"Create Task"}
   (0.1ms)  begin transaction
  SQL (0.3ms)  INSERT INTO "tasks" ("name", "created_at", "updated_at") VALUES (?, ?, ?)  [["name", "Buy a necklace"], ["created_at", 2016-07-07 23:22:50 UTC], ["updated_at", 2016-07-07 23:22:50 UTC]]
   (2.0ms)  commit transaction
Redirected to http://localhost:3000/tasks
Completed 200 OK in 4ms (ActiveRecord: 2.3ms)

Started GET "/tasks" for ::1 at 2016-07-07 16:22:50 -0700
Processing by TasksController#index as HTML
  Rendering tasks/index.html.erb within layouts/application
  Task Load (0.3ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."complete" = ?  [["complete", false]]
  Rendered collection of tasks/_task.html.erb [6 times] (5.2ms)
  Task Load (0.2ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."complete" = ?  [["complete", true]]
  Rendered collection of tasks/_task.html.erb [2 times] (1.2ms)
  Rendered tasks/index.html.erb within layouts/application (12.0ms)
Completed 200 OK in 36ms (Views: 33.6ms | ActiveRecord: 0.5ms)
```

Change the create action:

```ruby
def create
  @task = Task.create!(allowed_params)
  
  respond_to do |f|
    f.html { redirect_to tasks_url }
    f.js
  end
end
```

Create create.js.erb:

```rhtml
$('#new_task').remove();
$('#new_link').show();
$('#incomplete_tasks').append('<%= j render(@task) %>')
```

You can create a new task. The new task goes to the bottom of incomplete tasks list. There is no redirect when a new task is created.

```
Started POST "/tasks" for ::1 at 2016-07-07 16:30:09 -0700
Processing by TasksController#create as JS
  Parameters: {"utf8"=>"✓", "task"=>{"name"=>"Buy a puppy"}, "commit"=>"Create Task"}
   (0.1ms)  begin transaction
  SQL (0.3ms)  INSERT INTO "tasks" ("name", "created_at", "updated_at") VALUES (?, ?, ?)  [["name", "Buy a puppy"], ["created_at", 2016-07-07 23:30:09 UTC], ["updated_at", 2016-07-07 23:30:09 UTC]]
   (0.4ms)  commit transaction
  Rendering tasks/create.js.erb
  Rendered tasks/_task.html.erb (1.2ms)
  Rendered tasks/create.js.erb (2.9ms)
Completed 200 OK in 10ms (Views: 6.1ms | ActiveRecord: 0.7ms)
```

Remove link redirects as you can see in the log file:

```
Started DELETE "/tasks/13" for ::1 at 2016-07-07 18:13:44 -0700
Processing by TasksController#destroy as HTML
  Parameters: {"authenticity_token"=>"M60nBritB5vowdT03ZeulVOcC0NkNAfBdsKswwj5/HtqS0cdYVk6KLktRGZmNiuCvK2ITkZ/fJ5lR/BfKp1Isg==", "id"=>"13"}
  Task Load (0.2ms)  SELECT  "tasks".* FROM "tasks" WHERE "tasks"."id" = ? LIMIT ?  [["id", 13], ["LIMIT", 1]]
   (0.0ms)  begin transaction
  SQL (0.3ms)  DELETE FROM "tasks" WHERE "tasks"."id" = ?  [["id", 13]]
   (0.5ms)  commit transaction
Redirected to http://localhost:3000/tasks
Completed 302 Found in 3ms (ActiveRecord: 1.0ms)

Started GET "/tasks" for ::1 at 2016-07-07 18:13:44 -0700
Processing by TasksController#index as HTML
  Rendering tasks/index.html.erb within layouts/application
  Task Load (0.1ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."complete" = ?  [["complete", false]]
  Rendered collection of tasks/_task.html.erb [1 times] (1.0ms)
  Task Load (0.1ms)  SELECT "tasks".* FROM "tasks" WHERE "tasks"."complete" = ?  [["complete", true]]
  Rendered collection of tasks/_task.html.erb [2 times] (0.9ms)
  Rendered tasks/index.html.erb within layouts/application (4.9ms)
Completed 200 OK in 26ms (Views: 24.5ms | ActiveRecord: 0.2ms)
```

Add the remote flag to the remove link in task partial.

```rhtml
<%= link_to "(remove)", task, method: :delete, data: {confirm: "Are you sure?"}, remote: true %>
```

Change the destroy action to handle the ajax call.

```ruby
def destroy
  @task = Task.destroy(params[:id])
  
  respond_to do |f|
    f.html { redirect_to tasks_url }
    f.js
  end
end
```

Create destroy.js.erb:

```rhtml
$('#edit_task_<%= @task.id %>').remove();
```

Reload the tasks index page. Remove the task by clicking (remove):

```
Started DELETE "/tasks/1" for ::1 at 2016-07-07 18:26:33 -0700
Processing by TasksController#destroy as JS
  Parameters: {"id"=>"1"}
  Task Load (0.1ms)  SELECT  "tasks".* FROM "tasks" WHERE "tasks"."id" = ? LIMIT ?  [["id", 1], ["LIMIT", 1]]
   (0.0ms)  begin transaction
  SQL (1.6ms)  DELETE FROM "tasks" WHERE "tasks"."id" = ?  [["id", 1]]
   (0.4ms)  commit transaction
  Rendering tasks/destroy.js.erb
  Rendered tasks/destroy.js.erb (0.4ms)
Completed 200 OK in 10ms (Views: 3.8ms | ActiveRecord: 2.2ms)
```

Marking a task as complete without update button. Submit the form when the checkbox is clicked.

In tasks.js

```rhtml
$(function() {
	$('.edit_task input[type=checkbox]').click(function() {
		alert('clicked');
	});
});
```

Reload the tasks index page and click on the check box. Change the javascript to submit the form when the checkbox is clicked and remove all the update buttons.

```rhtml
$(function() {
	$('.edit_task input[type=submit]').remove();
	$('.edit_task input[type=checkbox]').click(function() {
		$(this).parent('form').submit();
	});
});
```

Reload the page. Check any incomplete tasks and you will see it moved to the Complete tasks section. You can also check the complete tasks and it will go into the incomplete tasks section.

Create a new task and you will see the update button show up again. To fix this, change tasks.js:

```javascript
jQuery.fn.submitOnCheck = function() {
	this.find('input[type=submit]').remove();
	this.find('input[type=checkbox]').click(function() {
		$(this).parent('form').submit();
	});
	return this;
}
```

```javascript
$(function() {
	$('.edit_task').submitOnCheck();
});
```

task partial, remote: true:

```rhtml
<%= form_for task, remote: true do |f| %>
  <%= f.check_box :complete %>
  <%= f.submit "Update" %>
  <%= f.label :complete, task.name %>
  <%= link_to "(remove)", task, method: :delete, data: {confirm: "Are you sure?"}, remote: true %>
<% end %>
```

Change the create.js.erb:

```rhtml
$('#new_task').remove();
$('#new_link').show();
$('#incomplete_tasks').append('<%= j render(@task) %>');
$('#edit_task_<%= @task.id %>').submitOnCheck();
```

```ruby
def update
  @task = Task.find(params[:id])
  @task.update_attributes!(allowed_params)
  
  respond_to do |f|
    f.html { redirect_to tasks_url }
    f.js
  end
end
``` 

update.js.erb:

```rhtml
<% if @task.complete? %>
  $('#edit_task_<%= @task.id %>').appendTo('#complete_tasks');
<% else %>
  $('#edit_task_<%= @task.id %>').appendTo('#incomplete_tasks');
<% end %>  
```

  



  


