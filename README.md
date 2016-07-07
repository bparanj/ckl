rails new ckl --skip-spring

rails g model task name complete:boolean

seeds.rb:

Task.create! name: "Meet Mr. Miyagi", complete: true
Task.create! name: "Paint the fence", complete: true
Task.create! name: "Wax the car"
Task.create! name: "Sand the deck"


rails g controller tasks index new 

Default complete flag to false.

class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.boolean :complete, default: false, null: false

      t.timestamps
    end
  end
end

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


routes.rb:

Rails.application.routes.draw do
  resources :tasks
  
  root to: 'tasks#index'
end


rails db:migrate
rails db:seed

index.html.erb:

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

task partial:

<%= form_for task do |f| %>
  <%= f.check_box :complete %>
  <%= f.submit "Update" %>
  <%= f.label :complete, task.name %>
  <%= link_to "(remove)", task, method: :delete, data: {confirm: "Are you sure?"} %>
<% end %>

