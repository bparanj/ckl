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
