class AbsencesController < ApplicationController


  def index
    @absence = Absence.new
  end

  def create
    @absence = current_student.absences.build(absence_params)
    
    if @absence.save
      redirect_to absences_path, notice: "欠席届を提出しました。"
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def absence_params
    params.require(:absence).permit(:kind, :reason, :detail, :target_date, periods: [])
  end
end
