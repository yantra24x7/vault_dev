module Api
  module V1
    require 'open-uri'

    #require 'open3'
class ProgramConfsController < ApplicationController
  before_action :set_program_conf, only: [:show, :update, :destroy]
  skip_before_action :authenticate_request, only: %i[file_list wifi_name_list wifi_config wifi_user_checking]
  # GET /program_confs
  def index
    
    @machines= Tenant.find(params[:tenant_id]).machines.pluck(:id)#.select{|c| c.program_conf != nil}
     @program_confs = ProgramConf.where(machine_id: @machines)
    render json: @program_confs
  end

  def part_doc_index
    if params["tenant_id"].present? && params["id"] == "ALL" || params["id"] == "undefined" && params["id"].present?
      mac_ids = Machine.where(tenant_id: params["tenant_id"]).pluck(:id)
      code_compare_reasons = CodeCompareReason.where(machine_id: mac_ids, is_active: true)
      render json: code_compare_reasons
    elsif params["id"] != "ALL" || params["id"] != "undefined" && params["id"].present?
      code_compare_reasons = CodeCompareReason.where(machine_id: params[:id], is_active: true)
      render json: code_compare_reasons
    else
      render json: {status: "Please Select the Machine"}
    end
  end

  def part_doc_edit
    @program_conf = CodeCompareReason.find(params[:id])
   
        if @program_conf.update(customername:params[:customername],job_name:params[:job_name])
      render json: @program_conf
    else
      render json: @program_conf.errors, status: :unprocessable_entity
    end

  end

  def part_doc_upload
    code_compare_reason = CodeCompareReason.find(params[:id])
    code_compare_reason.update(part_doc_path: params[:file])
    render json: "ok"
  end
  def file_download1 
     data = CodeCompareReason.find(params[:id])#.part_doc_path.url
    url = data.part_doc_path.url
    name = data.file_name
    send_file( "#{url}",
    filename: "#{name}.pdf",
    type: "application/pdf",
    x_sendfile: true
    )

    end

   def file_download12
    data = CodeCompareReason.find(params[:id])#.part_doc_path.url
    url = data.part_doc_path.url
    name = data.file_name
    send_file(
    "#{url}",
    filename: "#{name}.pdf",
    type: "application/pdf"
  )
    #render json: "#{name}.pdf"
  end

  def wifi_name_list
    @list_wifi = 'nmcli -f SSID dev wifi'
    Open3.popen3(@list_wifi) do |stdin, stdout, stderr, wait_thr|
      @data = stdout.read
    end
    render json: {wifi_name_list: @data}
  end

  def wifi_config
    system("sudo chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf")
    file_name = "wpa_supplicant.conf"
    dir = "/etc/wpa_supplicant/"
    if params[:user_name].present? && params[:password].present?
      read_data = File.open(File.join(dir, file_name), 'r'){|f| f.read}
      append_data = "\nnetwork={\nssid=\"#{params[:user_name]}\"\npsk=\"#{params[:password]}\"\nkey_mgmt=WPA-PSK\n}"
      old_id = read_data.object_id
      final_data = read_data << append_data
      File.open(File.join(dir, file_name), "wb") do |file|
        file.write(final_data)
      end
     system("sudo reboot")
      render json: {status: "true"}
    else
      render json: {status: "Give the user name and password"}
    end
  end

  def wifi_user_checking
    if params[:user_name].present?
      system("sudo chmod 777 /etc/wpa_supplicant/wpa_supplicant.conf")
      file_name = "wpa_supplicant.conf"
      dir = "/etc/wpa_supplicant"
      read_data = File.open(File.join(dir, file_name), 'r'){|f| f.read}
      if read_data.include?("#{params[:user_name]}")
        render json: {status: true}
      else
        render json: {status: false}
      end
    end
  end


  # GET /program_confs/1
  def show
    render json: @program_conf
  end

  # POST /program_confs
  def create
    machine = Machine.find(params[:machine_id])
    if machine.present?
      pp_dir = Rails.root.join('../..', "part_program")
      Dir.mkdir(pp_dir) unless Dir.exist?(pp_dir)
      mac_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}")
      Dir.mkdir(mac_dir) unless Dir.exist?(mac_dir)
      master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
      Dir.mkdir(master_dir) unless Dir.exist?(master_dir)
      slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
      Dir.mkdir(slave_dir) unless Dir.exist?(slave_dir)
      backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
      Dir.mkdir(backup_dir) unless Dir.exist?(backup_dir)

      if machine.program_conf.present?
        render json: {status: "Machine already have program conf"}
      else
        @program_conf = ProgramConf.new(program_conf_params)
        if @program_conf.save
          # render json: @program_conf, status: :created, location: @program_conf
          render json: {status: "File Created!!!"}
        else
          # render json: @program_conf.errors, status: :unprocessable_entity
          render json: {status: "something went wrong"}
        end
      end
    else
      render json: {status: "Machine Not Registered"}
    end


    # mac = Machine.find(params[:machine_id])
    # require 'net/ssh'
    # require 'net/sftp'
    # if mac.present?
    #   # con = mac.program_conf
    #   begin
    #     Net::SFTP.start(params["ip"], params["user_name"], :password => params["pass"], :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #     # Net::SFTP.start('192.168.0.152', 'admin', :password => 'Yantra24x7', :number_of_password_prompts => 0) do |sftp|
    #       sftp.mkdir! "#{params[:master_location]}/#{mac.machine_name.split('/').last}"
    #       sftp.mkdir! "#{params[:master_location]}/#{mac.machine_name.split('/').last}/Master"
    #       sftp.mkdir! "#{params[:slave_location]}/#{mac.machine_name.split('/').last}/Slave"
    #       sftp.mkdir! "#{params[:master_location]}/#{mac.machine_name.split('/').last}/Backup"

    #       if mac.program_conf.present?
    #         render json: {status: "Machine already have program conf"}
    #       else
    #         @program_conf = ProgramConf.new(program_conf_params)
    #         if @program_conf.save
    #           # render json: @program_conf, status: :created#, location: @program_conf
    #           render json: {status: "File Created!!!"}
    #         else
    #           # render json: @program_conf.errors#, status: :unprocessable_entity
    #           render json: {status: "something went wrong"}
    #         end
    #       end
    #     end
    #   rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
    #     puts e
    #     if e.message.include?('authentication failed')
    #       render json: {status: "Authentication failures"}
    #     elsif e.message.include?('Too many authentication failures')
    #       render json: {status: 'Authentication failures'}
    #     elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
    #       render json: {status: "Invalid IP"}
    #     elsif e.message.include?('no such file')
    #       render json: {status: "No Such File Master or Slave"}
    #     #elsif e.code == 4 || e.message.include?('failure')
    #     elsif e.message.include?('failure')
    #       render json: {status: "Folder Already Exists"}
    #     else
    #       # render json: {status: "Please Contact Yantra24x7"}
    #       render json: {status: "Authentication failed #{e.message}"}
	   #    end
    #   end
    # else
    #   render json: {status: "Machine Not Registered"}
    # end   
  end

  def file_send_to_cnc
    f_name = params[:file_name]
    machine = Machine.find(params[:machine_id])
    con = machine.program_conf
    if con.present?
      master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
      slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
      if Dir.exist?(master_dir)
        master_file_list = Dir.foreach(master_dir).select{|x| File.file?("#{master_dir}/#{x}")}
      
        if master_file_list.include?(params[:file_name])
          mac_ip = machine.machine_ip
          
          #dir = "/home/cnc/vault_dev"
          dir = "/home/altius/YANTRA"


          File.open(File.join(dir, "machine_ip"), 'wb') do |file|
            mac_ip = machine.machine_ip
            file.puts(mac_ip)
          end
             
          #system('gcc -I. upload.c -pthread -lfwlib32 -lstdc++ -o upload')
	        #system("./upload #{master_dir}/#{f_name}")
          old_Rec = CodeCompareReason.find_by(part_number: f_name, machine_id: params[:machine_id], is_active: true)
          reason = CodeCompareReason.create(part_number:f_name, user_id: current_user.id, user_name: current_user.first_name, machine_id: params[:machine_id], new_revision_no: old_Rec.new_revision_no, create_date: Time.now, old_revision_no: old_Rec.old_revision_no, description: "FILE UPLOADED TO CNC", file_name: old_Rec.file_name)         
          render json: {status: "File upload sucessfully"}
        else
          render json: {status: "File Not Exitst"}
        end
      else
        render json: {status: "Folder Not Exitst"}
      end
    else
      render json: {status: "Machine Not Registered in File Path"}
    end
  end



def file_receive_from_cnc
    f_name = params[:file_name]
    machine = Machine.find(params[:machine_id])
    con = machine.program_conf
    if con.present?
      master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
      slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
      if Dir.exist?(master_dir)
        master_file_list = Dir.foreach(master_dir).select{|x| File.file?("#{master_dir}/#{x}")}
      
        if master_file_list.include?(params[:file_name])
          mac_ip = machine.machine_ip
          
          #dir = "/home/cnc/vault_dev"
          dir = "/home/altius/YANTRA"

          File.open(File.join(dir, "machine_ip"), 'wb') do |file|
            mac_ip = machine.machine_ip
            file.puts(mac_ip)
          end
            d_file = f_name.split("O").last

	         #system('gcc -I. download.c -pthread -lfwlib32 -lstdc++ -o download')
           #system("./download #{slave_dir}/#{f_name} #{d_file}")
           old_Rec = CodeCompareReason.find_by(part_number: f_name, machine_id: params[:machine_id], is_active: true)
          reason = CodeCompareReason.create(part_number:f_name, user_id: current_user.id, user_name: current_user.first_name, machine_id: params[:machine_id], new_revision_no: old_Rec.new_revision_no, create_date: Time.now, old_revision_no: old_Rec.old_revision_no, description: "FILE DWONLOAD FROM CNC", file_name: old_Rec.file_name)

         
          render json: {status: "File download sucessfully"}
        else
          render json: {status: "File Not Exitst"}
        end
      else
        render json: {status: "Folder Not Exitst"}
      end
    else
      render json: {status: "Machine Not Registered in File Path"}
    end
  end



  def file_upload
    machine = Machine.find(params[:machine_id])
    if machine.program_conf.present?
      con = machine.program_conf
      file_name = params[:file].original_filename
      file_extension = file_name.split('.')
      if file_extension.last.include?("nc") || file_extension.count == 1
        master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
        file = params[:file]
        if Dir.exist?(master_dir)
          unless CodeCompareReason.where(file_name:file_name, machine_id: params[:machine_id]).present?
            File.open(master_dir.join(file.original_filename), 'wb') do |file1|
              file1.write(file.read)
            end
            reason = CodeCompareReason.create(user_id: current_user.id, part_number:file_name, user_name: current_user.first_name, machine_id: params[:machine_id], new_revision_no: params[:revision_no], create_date: Time.now, old_revision_no: "-", description: "NEW FILE SAVED", file_name: params[:file].original_filename, is_active: true)
            render json: {status: "File Upload"}
          else
           render json: {status: "Already This File Upload"} 
          end    
       else
          render json: {status: "Folder Not Exitst"}
        end
      else
        render json: {status: "File Extension doesn't support. kindly change your file extension as .nc or file"}
      end
    else
      render json: {status: "Machine Not Registered in File Path"}
    end


    # require 'net/sftp'
    # # require 'rufus-scheduler'
    # # require 'rubygems'
    # # require 'rufus/scheduler'
    # # require 'rake'
    # mac = Machine.find(params["machine_id"])
    # if mac.program_conf.present?
    #   con = mac.program_conf
    #   #scheduler = Rufus::Scheduler::PlainScheduler.start_new(:frequency => 3.0)
    #   # byebug 
    #   begin
    #     Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #       puts "Connection OK!"
    #       file_name = params[:file].original_filename
    #       file_extension = file_name.split('.')
    #       if file_extension.last.include?("nc") || file_extension.count == 1
    #         mas = sftp.dir.entries("#{con.master_location}/#{mac.machine_name.split('/').last}/Master").present?
    #         if mas == true
    #           sftp.upload!(params[:file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file].original_filename}") # _M#{DateTime.now}")
    #           path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file].original_filename}"
    #           reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:machine_id], new_revision_no: params[:revision_no], create_date: params[:date], old_revision_no: "-", description: "NEW UPLOADED", file_name: params[:file].original_filename)
    #           render json: {status: "File Upload"}
    #         else
    #           sftp.upload!(params[:file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file].original_filename}") # _M#{DateTime.now}")
    #           path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file].original_filename}"
    #           reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:machine_id], new_revision_no: params[:revision_no], create_date: params[:date], old_revision_no: "-", description: "NEW UPLOADED", file_name: params[:file].original_filename)
    #           render json: {status: "File Upload"}
    #         end
    #       else
    #         render json: {status: "File Extension doesn't support. kindly change your file extension as .nc or file"}
    #       end
    #     end
    #   rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e
    #     unless e.message == "exit"
    #       #puts "Error: #{e.message}"
    #       if e.message.include?("authentication failures")
    #         render json: {status: "Authentication failed"}
    #       elsif e.message.include?('Authentication failed for user')
    #         render json: {status: "Invalid IP"}
    #       elsif e.message.include?("Connection refused")
    #         render json: {status: "Authentication failed"}
    #       else
    #         render json: {status: "Folder Not Exitst"}
    #       end
    #       #exit 2
    #     end
    #   end
    # else
    #   render json: {status: "Machine Not Registered in File Path"}
    # end
  end

 


  def file_upload1
    
    require 'net/sftp'
    # require 'rufus-scheduler'
    # require 'rubygems'
    # require 'rufus/scheduler'
    # require 'rake'
    mac = Machine.find(params["machine_id"])
    if mac.program_conf.present?
      con = mac.program_conf
      #scheduler = Rufus::Scheduler::PlainScheduler.start_new(:frequency => 3.0)
      # byebug 
      begin
        Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
          puts "Connection OK!"
         # send_data "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/sample.txt", filename: "aaa.txt"
          @data = sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/sample.txt")

          #sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/sample.txt", "D:\Projects")
          # mas = sftp.dir.entries("#{con.master_location}/#{mac.machine_name.split('/').last}/Master").present?
          # if mas == true
          #   sftp.upload!(params[:file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file].original_filename}") # _M#{DateTime.now}")
          #   reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 1, status: false, file_path: nil) # 1 means upload
          #   render json: {status: "File Upload"}
          # else
          #   sftp.upload!(params[:file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file].original_filename}") # _M#{DateTime.now}")
          #   reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 1, status: false, file_path: nil) # 1 means upload
          #   render json: {status: "File Upload"}
          # end
        end
      rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e
        unless e.message == "exit"
          #puts "Error: #{e.message}"
          if e.message.include?("authentication failures")
            render json: {status: "Authentication failed"}
          elsif e.message.include?('Authentication failed for user')
            render json: {status: "Invalid IP"}
          elsif e.message.include?("Connection refused")
            render json: {status: "Authentication failed"}
          else
            render json: {status: "Folder Not Exitst"}
          end
          #exit 2
        end
      end
    else
      render json: {status: "Machine Not Registered in File Path"}
    end
    send_data @data, filename: "aaa.txt"
  end


  def file_list
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
        slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
        if Dir.exist?(master_dir) && Dir.exist?(slave_dir)
          master_file_list = Dir.foreach(master_dir).select{|x| File.file?("#{master_dir}/#{x}")}
          slave_file_list = Dir.foreach(slave_dir).select{|x| File.file?("#{slave_dir}/#{x}")}
          render json: {master_location: master_file_list, slave_location: slave_file_list}
        else
          render json: {status: "Folder Not Exitst"}
        end
      else
        render json: {status: "Machine Not Registered in File Path"}
      end
    else
      # render json: {status: "Give the id for machine"}
      render json: {status: "Please Select the Machine"}
    end


    # @master_location = []
    # @slave_location = []
    # require 'net/sftp'
    # if params[:id].present?
    #   mac = Machine.find(params["id"])
    #   con = mac.program_conf
    #   if con.present?
    #     begin
    #       # Net::SFTP.start(con.ip, con.user_name, :password => con.pass) do |sftp|
    #       Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #         # sftp.dir.foreach("#{con.master_location}/#{mac.machine_name.split('/').last}/Master") do |entry|
    #         sftp.dir.glob("#{con.master_location}/#{mac.machine_name.split('/').last}/Master", "**/*") do |entry|
    #           @master_location << entry
    #         end
    #         # sftp.dir.foreach("#{con.slave_location}/#{mac.machine_name.split('/').last}/Slave") do |entry1|
    #         sftp.dir.glob("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave", "**/*") do |entry1|
    #           @slave_location << entry1
    #         end
    #       end
    #       render json: {master_location: @master_location, slave_location: @slave_location}
    #     rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
    #       puts e
    #       if e.message.include?('authentication failure')
    #         render json: {status: "Authentication failed"}
    #       elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
    #         render json: {status: "Invalid IP"}
    #       elsif e.message.include?('no such file') # || (e.code == 2)
    #         render json: {status: "No Such File Master or Slave"}
    #       else
	   #  # render json: {status: "Please Contact Yantra24x7"}
    #         render json: {status: "Authentication failed"}
    #       end
    #     end
    #   else
    #     # render json: {status: "This machine doesn't have program conf"}
    #     render json: {status: "Machine Not Registered in File Path"}
    #   end
    # else
    #   render json: {status: "Give the id for machine"}
    # end
  end


# ==================================================  The following two methods are written by UMA =================================================
  def file_delete
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        file_name = params[:file_name]
        if file_name.present?
          master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
          slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
          backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
          if Dir.exist?(master_dir) && Dir.exist?(slave_dir) && Dir.exist?(backup_dir)
            if params[:position] == "Master"
              master_file = master_dir.join(file_name)
              file_delete = File.delete(master_file)
            elsif params[:position] == "Slave"
              slave_file = slave_dir.join(file_name)
              file_delete = File.delete(slave_file)
            elsif params[:position] == "Backup"            
              backup_file = backup_dir.join(file_name)
              file_delete = File.delete(backup_file)
            end
            reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:id], description: params[:reason], create_date: params[:date], file_name: params[:file_name])
            render json: {status: "Deleted Successfully"}
          else
            render json: {status: "Folder Not Exitst"}
          end
        else
           render json: {status: "File Name Not Exitst"}
        end
      else
        render json: {status: "Machine Not Registered in File Path"}
      end
    else
      render json: {status: "Please Select the Machine"}
    end


    # if params[:id].present?
    #   mac = Machine.find(params[:id])
    #   con = mac.program_conf
    #   if con.present?
    #     begin
    #       Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #         if params[:position] == "Master"
    #           path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file_name]}"
    #           sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file_name]}").wait
    #           reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:id], description: params[:reason], create_date: params[:date], file_name: params[:file_name])
	   #  elsif params[:position] == "Slave"
    #           path = "#{con.slave_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:file_name]}"
    #           sftp.remove("#{con.slave_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:file_name]}").wait
    #           reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:id], description: params[:reason], create_date: params[:date], file_name: params[:file_name])
    #         end
    #       end
    #       render json: {status: "Deleted Successfully"}
    #     rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
    #       puts e
    #       if e.message.include?('authentication failure')
    #         render json: {status: "Authentication failed"}
    #       elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
    #         render json: {status: "Invalid IP"}
    #       elsif e.message.include?('no such file') # || (e.code == 2)
    #         render json: {status: "No Such File Master or Slave"}
    #       else
    #         # render json: {status: "Please Contact Yantra24x7"}
    #         render json: {status: "Authentication failed"}
    #       end
    #     end
    #   else
    #     # render json: {status: "This machine doesn't have program conf"}
    #     render json: {status: "Machine Not Registered in File Path"}
    #   end
    # else
    #   render json: {status: "Select the Machine"}
    # end
  end

  def file_path
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        path = "#{con.ip}/#{con.master_location}/#{machine.machine_name.split('/').last}"
       # byebug
        path = "//yantra.local/#{con.master_location.split("/").last}/#{machine.machine_name.split('/').last}" 
      render json: {file_path: path}, status: :ok
      else
        render json: {status: "Machine Not Registered in File Path"}
      end
    else
      render json: {status: "Please Select the Machine"}
    end

  #   if params[:id].present?
  #     mac = Machine.find(params[:id])
  #     con = mac.program_conf
  # # byebug
  #     if con.present?
  #       # if con.master_location == con.slave_location
  # #      path = "#{con.ip}/#{con.master_location}/#{mac.machine_name.split('/').last}"
	 # path = "#{con.ip}"
  #       # end
  #       render json: {file_path: path}, status: :ok
  #     else
  #       render json: {status: "Machine Not Registered in File Path"}
  #     end
  #   else
  #     render json: {status: "Please Select the Machine"}
  #   end
  end

  def compare_reason
    if params[:id].present?
      mac = Machine.find(params[:id])
      con = mac.program_conf
      if con.present?
        # path = "#{con.master_location}/#{mac.machine_name.split('/').last}"
        path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file_name]}"

        reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 5, status: true, file_path: path) # 5 means code compare
        render json: {status: "Reason is created"}
      else
        render json: {status: "Machine Not Registered in File Path"}
      end
    else
      render json: {status: "Please Select the Machine"}
    end
  end

  def backup_file_list
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
        if Dir.exist?(backup_dir)
          backup_file_list = Dir.foreach(backup_dir).select{|x| File.file?("#{backup_dir}/#{x}")}
          render json: {backup_location: backup_file_list}
        else
          render json: {status: "Folder Not Exitst"}
        end
      else
        render json: {status: "Machine Not Registered in File Path"}
      end
    else
      # render json: {status: "Give the id for machine"}
      render json: {status: "Please Select the Machine"}
    end

    # @backup_location = []
    # require 'net/sftp'
    # if params[:id].present?
    #   mac = Machine.find(params["id"])
    #   con = mac.program_conf
    #   if con.present?
    #     begin
    #       Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #         sftp.dir.glob("#{con.master_location}/#{mac.machine_name.split('/').last}/Backup", "**/*") do |entry|
    #           @backup_location << entry
    #         end
    #       end
    #       render json: {backup_location: @backup_location}
    #     rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
    #       puts e
    #       if e.message.include?('authentication failure')
    #         render json: {status: "Authentication failed"}
    #       elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
    #         render json: {status: "Invalid IP"}
    #       elsif e.message.include?('no such file') # || (e.code == 2)
    #         render json: {status: "No Such File Master or Slave"}
    #       else
    #         # render json: {status: "Please Contact Yantra24x7"}
    #         render json: {status: "Authentication failed"}
    #       end
    #     end
    #   else
    #     # render json: {status: "This machine doesn't have program conf"}
    #     render json: {status: "Machine Not Registered in File Path"}
    #   end
    # else
    #   render json: {status: "Give the id for machine"}
    # end
  end

  def file_download
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        file_name = params[:file_name]
        master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
        slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
        backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
        
        if Dir.exist?(master_dir) && Dir.exist?(slave_dir) && Dir.exist?(backup_dir)
          if params[:position] == "Master"
            master_file = master_dir.join(file_name)
            File.open(file_name, 'wb'){|f| f << master_file}
            send_file(master_file, :filename => file_name)
          elsif params[:position] == "Slave"
            slave_file = slave_dir.join(file_name)
            File.open(file_name, 'wb'){|f| f << slave_file}
            send_file( slave_file, :filename => file_name)
          elsif params[:position] == "Backup"
            backup_file = backup_dir.join(file_name)
            File.open(file_name, 'wb'){|f| f << backup_file}
            send_file(backup_file, :filename => file_name)
          end
        else
          render json: {status: "Folder Not Exitst"}
        end
        
      else
        render json: {status: "Machine Not Registered in File Path"}
      end
    else
      # render json: {status: "Give the id for machine"}
      render json: {status: "Please Select the Machine"}
    end


    # if params[:id].present?
    #   mac = Machine.find(params[:id])
    #   con = mac.program_conf
    #   if con.present?
    #     begin
    #       Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #         file_name = params[:file_name]
    #         if params[:position] == "Master"
    #           data = sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
    #           File.open(file_name, "wb"){|f| f << data}
    #           send_file( file_name, :filename => file_name )
    #         elsif params[:position] == "Slave"
    #           data = sftp.download!("#{con.slave_location}/#{mac.machine_name.split('/').last}/Slave/#{file_name}")
    #           File.open(file_name, "wb"){|f| f << data}
    #           send_file( file_name, :file_name => file_name )
    #         elsif params[:position] == "Backup"
    #           data = sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{file_name}")
    #           File.open(file_name, "wb"){|f| f << data}
    #           send_file( file_name, :file_name => file_name )
    #         end
    #       end
    #     rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
    #       puts e
    #       if e.message.include?('authentication failure')
    #         render json: {status: "Authentication failed"}
    #       elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
    #         render json: {status: "Invalid IP"}
    #       elsif e.message.include?('no such file') # || (e.code == 2)
    #         render json: {status: "No Such File Master or Slave"}
    #       else
    #         # render json: {status: "Please Contact Yantra24x7"}
    #         render json: {status: "Authentication failed"}
    #       end
    #     end
    #   else
    #     # render json: {status: "This machine doesn't have program conf"}
    #     render json: {status: "Machine Not Registered in File Path"}
    #   end
    # else
    #   render json: {status: "Select the Machine"}
    # end
  end


  def backup_upload
    machine = Machine.find(params[:machine_id])
    if machine.program_conf.present?
      con = machine.program_conf
      backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
      file = params[:file]
      if Dir.exist?(backup_dir)
        File.open(backup_dir.join(file.original_filename), 'wb') do |file|
          file.write(file.read)
        end
        reason = CodeCompareReason.create(user_name: "-", machine_id: params[:machine_id], description: params[:reason], old_revision_no: "-", new_revision_no: "-", file_name: params[:file].original_filename)
        render json: {status: "File Upload"}
      else
        render json: {status: "Folder Not Exitst"}
      end
    else
      render json: {status: "Machine Not Registered in File Path"}
    end


    # require 'net/sftp'
    # mac = Machine.find(params["machine_id"])
    # if mac.program_conf.present?
    #   con = mac.program_conf
    #   begin
    #     Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
    #       puts "Connection OK!"
    #       mas = sftp.dir.entries("#{con.master_location}/#{mac.machine_name.split('/').last}/Backup").present?
    #       if mas == true
    #         sftp.upload!(params[:file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{params[:file].original_filename}") # _M#{DateTime.now}")
    #         path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{params[:file].original_filename}"
    #         reason = CodeCompareReason.create(user_name: "-", machine_id: params[:machine_id], description: params[:reason], old_revision_no: "-", new_revision_no: "-", file_name: params[:file].original_filename) #user_id: params[:user_id],, current_location: 4, status: false, file_path: path) # 4 means upload from backup
    #         render json: {status: "File Upload"}
    #       else
    #         sftp.upload!(params[:file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{params[:file].original_filename}") # _M#{DateTime.now}")
    #         path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{params[:file].original_filename}"
    #         reason = CodeCompareReason.create(user_name: "-", machine_id: params[:machine_id], description: params[:reason], old_revision_no: "-", new_revision_no: "-", file_name: params[:file].original_filename) #,user_id: params[:user_id],current_location: 4, status: false, file_path: path) # 4 means upload from backup
    #         render json: {status: "File Upload"}
    #       end
    #     end
    #   rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e
    #     unless e.message == "exit"
    #       #puts "Error: #{e.message}"
    #       if e.message.include?("authentication failures")
    #         render json: {status: "Authentication failed"}
    #       elsif e.message.include?('Authentication failed for user')
    #         render json: {status: "Invalid IP"}
    #       elsif e.message.include?("Connection refused")
    #         render json: {status: "Authentication failed"}
    #       else
    #         render json: {status: "Folder Not Exitst"}
    #       end
    #       #exit 2
    #     end
    #   end
    # else
    #   render json: {status: "Machine Not Registered in File Path"}
    # end
  end


    def file_move1
    if params[:id].present?
      mac = Machine.find(params[:id])
      con = mac.program_conf

      if con.present?
        begin
          Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :number_of_password_prompts => 0) do |sftp|
            # file_name = params[:file_name]
              # slave_file = params[:new_file].present? ? params[:new_file] : params[:slave_file].original_filename
              slave_file = params[:slave_file].original_filename
              # slave_file1 = params[:slave_file].split("R")
              # slave_file1 = slave_file.split('R')
              slave_file1 = slave_file.split('-')

              path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file_name]}"
              # file_name = "#{slave_file1.first}#{slave_file1.last}"
              
              if slave_file1.count == 1
                file_name = "#{slave_file1.first}"
              elsif slave_file1.count == 2
                file_name = "#{slave_file1.first}"
              else
                file_name = "#{slave_file1.first.split('-').first}#{slave_file1.last}"
              end
              # file_name = "#{slave_file1.first.split('-').first}#{slave_file1.last}"
              
              if File.exist?(file_name)
                entries = sftp.dir.entries("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/").sort_by(&:name)
                # entries.map do |i|
                #   @file_status = i.name.include? file_name  
                # end
                @file_status = entries.map {|i| file_status = i.name.include? file_name }
                # if @file_status == true
                
                if @file_status.include?(true)
                  data = sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
                  
                  write_file = File.open(file_name, "wb"){|f| f << data}
                  @open_file = File.open(write_file, 'r')
                  dir = Rails.root.join('public', 'uploads', 'Master')
                  # write_file = File.open(dir.join(file_name), 'wb') do |file|
                  
                  File.open(dir.join(file_name), 'wb') do |file|
                    file.write(@open_file.read)
                    # file.write(@a)
                    @file_path = file.path
                  end
                 # byebug
                  # time = Time.now.strftime('%d%m%Y%H%M%S%z')
                  time = Time.now.strftime('%d%b%y|%H%M%S%z')
                  # backup_file = "#{slave_file1.first.split('-').first}_#{time}#{slave_file1.last}"
                  # backup_file = "#{slave_file1.first.first}_#{time}#{slave_file1.last}"
                  backup_file = "#{slave_file1.first}_#{time}"
                  byebug
                  upload = sftp.upload!(@file_path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{backup_file}")
                 # byebug
                  if upload.present?
                     file_delete = File.delete(Rails.root + @file_path)
                     byebug
                    if file_delete == 1
                      byebug
                      # sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}").wait
                      master_upload = sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
			puts "#{params[:slave_file].original_filename}"
                      sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:slave_file].original_filename}").wait
		#	sf = File.open(slave_file, 'wb'){|f| f << data}
		#	write_data = File.open(sf, 'r')
		#	file_data = sf.read
		#	File.delete(sf)
		    else
			 master_upload = sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
                         puts "#{params[:slave_file].original_filename}"
                        sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:slave_file].original_filename}").wait
                    end
                  end
                else
                  sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
		  sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:slave_file].original_filename}").wait
                end
              else
                entries = sftp.dir.entries("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/").sort_by(&:name)
                # entries.map do |i|
                #   @file_status = i.name.include? file_name  
                # end
                @file_status = entries.map {|i| file_status = i.name.include? file_name }
                # if @file_status == true
                
                if @file_status.include?(true)
                  data = sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
                  write_file = File.open(file_name, "wb"){|f| f << data}
                  @open_file = File.open(write_file, 'r')
                  dir = Rails.root.join('public', 'uploads', 'Master')
                  # write_file = File.open(dir.join(file_name), 'wb') do |file|
                  File.open(dir.join(file_name), 'wb') do |file|
                    file.write(@open_file.read)
                    # file.write(@a)
                    @file_path = file.path
                  end
                  # time = Time.now.strftime('%d%m%Y%H%M%S%z')
                  time = Time.now.strftime('%d%b%y|%H%M%S%z')
                  # backup_file = "#{slave_file1.first.split('-').first}_#{time}#{slave_file1.last}"
                  # backup_file = "#{slave_file1.first.first}_#{time}#{slave_file1.last}"
                  backup_file = "#{slave_file1.first}_#{time}"
                 # byebug
                  upload = sftp.upload!(@file_path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{backup_file}")
                  if upload.present?
                     file_delete = File.delete(Rails.root + @file_path)
                    if file_delete == 1
                      # sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}").wait
                      master_upload = sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
                      sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:slave_file].original_filename}").wait
#			sf = File.open(slave_file, 'wb')
 #                       file_data = sf.read
  #                      File.delete(sf)
		    else
                         master_upload = sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
                         puts "#{params[:slave_file].original_filename}"
                        sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:slave_file].original_filename}").wait

                    end
                  end
                else
                  sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
		  sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Slave/#{params[:slave_file].original_filename}").wait
                end
                # sftp.upload!(params[:slave_file].path, "#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file_name}")
              end
              # reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 5, status: true, file_path: path) # 5 means code compare
                   
                   reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:id], old_revision_no: params[:old_revision_no], new_revision_no: params[:new_revision_no], create_date: params[:date], description: params[:reason], file_name: params[:file_name])
              render json: { status: "File Moved Successfully"}
          end
        rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
          puts e
          if e.message.include?('authentication failure')
            render json: {status: "Authentication failed"}
          elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
            render json: {status: "Invalid IP"}
          elsif e.message.include?('no such file') # || (e.code == 2)
            render json: {status: "No Such File Master or Slave"}
          else
            # render json: {status: "Please Contact Yantra24x7"}
            render json: {status: "#{e.message}"}
	  end
        end
      else
        # render json: {status: "This machine doesn't have program conf"}
        render json: {status: "Machine Not Registered in File Path", file_name: "#{params[:slave_file].original_filename}"}
      end
    else
      render json: {status: "Select the Machine"}
    end
  end





  # def move_file
  #   if params[:id].present?
  #     mac = Machine.find(params[:id])
  #     con = mac.program_conf
  #     if con.present?
  #       begin
  #         # Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
  #         Net::SFTP.start(con.ip, con.user_name, :password => con.pass, :timeout => 15, :number_of_password_prompts => 0) do |sftp|
  #           if params[:position] == "Master"
  #       # byebug
  #             sftp.dir.glob("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/", params[:file_name]) do |file|
  #       # byebug
  #               sftp.download!("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{file.name}", "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{file.name}")

  #               path = "#{con.master_location}/#{mac.machine_name.split('/').last}/Backup/#{file.name}"
  #               reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 3, status: false, file_path: path) # 3 for Backup
  #             end
  #               sftp.remove("#{con.master_location}/#{mac.machine_name.split('/').last}/Master/#{params[:file_name]}").wait
  #               reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 3, status: false, file_path: nil)
                
  #              # sftp.download!("#{con.master_location}/#{mac.machine_ip}/Master/#{params[:file_name]}", "#{con.master_location}/#{mac.machine_ip}/Backup/")
  #              render json: {status: "File Successfully moved from Master to Backup"}

  #           elsif params[:position] == "Slave"
  #             sftp.dir.glob("#{con.master_location}/#{mac.machine_ip}/Slave/", params[:file_name]) do |file|
  #               sftp.download!("#{con.master_location}/#{mac.machine_ip}/Slave/#{file.name}", "#{con.master_location}/#{mac.machine_ip}/Backup/#{file.name}")
  #               path = "#{con.master_location}/#{mac.machine_ip}/Backup/#{file.name}"
  #               # reason = reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 3, status: false, file_path: path)
  #             end
  #           end
  #             sftp.remove("#{con.master_location}/#{mac.machine_ip}/Slave/#{params[:file_name]}")
  #             # reason = CodeCompareReason.create(user_id: params[:user_id], machine_id: params[:id], description: params[:reason], current_location: 4, status: false, file_path: path)

  #             render json: {status: "File Successfully moved from Slave to Backup"}
  #         end
  #       rescue Net::SSH::Exception, Net::SFTP::Exception, SystemCallError => e 
  #         puts e
  #   # byebug
  #         if e.message.include?('authentication failure')
  #           render json: {status: "Authentication failed"}
  #         elsif e.message.include?('No route to host') || e.message.include?('Authentication failed for user')
  #           render json: {status: "Invalid IP"}
  #         elsif e.message.include?('no such file') # || (e.code == 2)
  #           render json: {status: "No Such File Master or Slave"}
  #         else
  #           render json: {status: "Please Contact Yantra24x7"}
  #         end
  #       end
  #     else
  #       render json: {status: "This Machine doesn't have program conf"}
  #     end
  #   else
  #     render json: {status: "Select the Machine"}
  #   end
  # end
# ==================================================  The above two methods are written by UMA =====================================================

  # PATCH/PUT /program_confs/1
  def update
    if @program_conf.update(program_conf_params)
      render json: @program_conf
    else
      render json: @program_conf.errors, status: :unprocessable_entity
    end
  end

  # DELETE /program_confs/1
  def destroy
    @program_conf.destroy
  end


  def file_move
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
        slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
        backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
        master_file_name = params[:file_name]
        slave_file_name = params[:slave_file].original_filename
        

        file_extension = slave_file_name.split('.')
        if file_extension.last.include?("nc") || file_extension.count == 1
          slave_name_check = file_extension.first.split('-')
          
          #if slave_name_check.count == 2 && slave_name_check.last == "R"
            slave_file1 = slave_file_name.split('-')
            
            if slave_file1.count == 1
              file_name = "#{slave_file1.first}"
            elsif slave_file1.count == 2
              file_name = "#{slave_file1.first}"
            else
              file_name = "#{slave_file1.first.split('-').first}#{slave_file1.last}"
            end
            
            if CodeCompareReason.where(machine_id: params[:id], file_name: params[:file_name],is_active: true).present?
            old_Rec = CodeCompareReason.where(machine_id: params[:id], file_name: params[:file_name],is_active: true).first
            time = Time.now.strftime('%d-%m-%Y-%H-%M-%S')
            
            backup_file_name = "#{file_name}_version#{old_Rec.new_revision_no}_cc_#{time}"
            if Dir.exist?(master_dir) && Dir.exist?(slave_dir) && Dir.exist?(backup_dir)
              master_file_list = Dir.foreach(master_dir).select{|x| File.file?("#{master_dir}/#{x}")}
              slave_file_list = Dir.foreach(slave_dir).select{|x| File.file?("#{slave_dir}/#{x}")}
              #backup to path
              if slave_file_list.include?(slave_file_name)
              if master_file_list.include?(master_file_name)
                # master_file = master_dir.join(master_file_name)
                master_file = master_dir.join(file_name)
                master_write_file = File.open(file_name, "wb"){|f| f << master_file}
                # @master_open_file = File.open(master_write_file, 'r')
                @master_open_file = File.open(master_file, 'r')
                File.open(backup_dir.join(backup_file_name), 'wb') do |file|
                  file.write(@master_open_file.read)
                  @backup_file_path = file.path
                end
 
               #Slave to Master
                if @backup_file_path.present?
                  slave_file = slave_dir.join(slave_file_name)
                slave_write_file = File.open(slave_file_name, "wb"){|f| f << slave_file}
                @slave_open_file = File.open(slave_file, 'r')
                  File.open(master_dir.join(file_name), 'wb') do |file|
                  
                    file.write(@slave_open_file.read)

                    @master_file_path = file.path
                  end
                  if @master_file_path.present?
                    slave_file = slave_dir.join(slave_file_name)
                    file_delete = File.delete(slave_file)
                  end
                end
              else
                File.open(master_dir.join(file_name), 'wb') do |file|
                  file.write(file.read)
                  @master_file_path = file.path
                end
                if @master_file_path.present?
                  slave_file = slave_dir.join(slave_file_name)
                  file_delete = File.delete(slave_file)
                end
              end
             
              reason = CodeCompareReason.create(part_number:old_Rec.part_number, user_id: current_user.id, user_name: current_user.first_name, machine_id: params[:id], old_revision_no: old_Rec.new_revision_no, new_revision_no: old_Rec.new_revision_no.to_i + 1, create_date: Time.now, description: "FILE UPDATE(#{params[:reason]})", file_name: old_Rec.file_name)
              old_Rec.update(new_revision_no: old_Rec.new_revision_no.to_i + 1)
              #reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:id], old_revision_no: params[:old_revision_no], new_revision_no: params[:new_revision_no], create_date: params[:date], description: params[:reason], file_name: params[:file_name])
              render json: {status: "File Moved Successfully"}
             else
              render json: {status: "File Not Exitst Slave Path"}
             end
            else
              render json: {status: "Folder Not Exitst"}
            end
         else
           render json: {status: "File Not Exitst "}
          end
        else
          render json: {status: "File Extension doesn't support. kindly change your file extension as .nc or file"}
        end
       
      else
        render json: {status: "Machine Not Registered in File Path"}
      end         
    else
      render json: {status: "Please Select the Machine"}
    end
  end
  
   def file_move1
    if params[:id].present?
      machine = Machine.find(params[:id])
      con = machine.program_conf
      if con.present?
        master_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Master")
        slave_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Slave")
        backup_dir = Rails.root.join('../..', "part_program", "#{machine.machine_name.split('/').last}", "Backup")
        master_file_name = params[:file_name]
        slave_file_name = params[:slave_file].original_filename
        byebug
        file_extension = slave_file_name.split('.')
        if file_extension.last.include?("nc") || file_extension.count == 1
          slave_name_check = file_extension.first.split('-')
          if slave_name_check.count == 2 && slave_name_check.last == "R"
            slave_file1 = slave_file_name.split('-')
            if slave_file1.count == 1
              file_name = "#{slave_file1.first}"
            elsif slave_file1.count == 2
              file_name = "#{slave_file1.first}"
            else
              file_name = "#{slave_file1.first.split('-').first}#{slave_file1.last}"
            end
            time = time = Time.now.strftime('%d%m%Y%H%M%S%z')
            backup_file_name = "#{file_name}_cc_#{time}"
            if Dir.exist?(master_dir) && Dir.exist?(slave_dir) && Dir.exist?(backup_dir)
              master_file_list = Dir.foreach(master_dir).select{|x| File.file?("#{master_dir}/#{x}")}
              if master_file_list.include?(master_file_name)
                # master_file = master_dir.join(master_file_name)
                master_file = master_dir.join(file_name)
                master_write_file = File.open(file_name, "wb"){|f| f << master_file}
                # @master_open_file = File.open(master_write_file, 'r')
                @master_open_file = File.open(master_file, 'r')
                File.open(backup_dir.join(backup_file_name), 'wb') do |file|
                  file.write(@master_open_file.read)
                  @backup_file_path = file.path
                end
                if @backup_file_path.present?
                  File.open(master_dir.join(file_name), 'wb') do |file|
                    file.write(file.read)
                    @master_file_path = file.path
                  end
                  if @master_file_path.present?
                    slave_file = slave_dir.join(slave_file_name)
                    file_delete = File.delete(slave_file)
                  end
                end
              else
                File.open(master_dir.join(file_name), 'wb') do |file|
                  file.write(file.read)
                  @master_file_path = file.path
                end
                if @master_file_path.present?
                  slave_file = slave_dir.join(slave_file_name)
                  file_delete = File.delete(slave_file)
                end
              end
              reason = CodeCompareReason.create(user_name: params[:user_name], machine_id: params[:id], old_revision_no: params[:old_revision_no], new_revision_no: params[:new_revision_no], create_date: params[:date], description: params[:reason], file_name: params[:file_name])
              render json: {status: "File Moved Successfully"}
            else
              render json: {status: "Folder Not Exitst"}
            end
          else
            render json: {status: "Kindly change your slave file name with -R"}
          end
        else
          render json: {status: "File Extension doesn't support. kindly change your file extension as .nc or file"}
        end
       
      else
        render json: {status: "Machine Not Registered in File Path"}
      end         
    else
      render json: {status: "Please Select the Machine"}
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_program_conf
      @program_conf = ProgramConf.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def program_conf_params
      params.require(:program_conf).permit(:ip, :user_name, :pass, :master_location, :slave_location, :machine_id)
    end
end
end
end
