	require 'rubygems'
	require 'nokogiri'
	require 'open-uri'
	require 'google_drive'
	require 'gmail'
	require 'pry'
# a toi de mettre ton fichier json dans le dossier!!!!

#fonction qui scrappe les liens des mairies
	def get_url
		page = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/manche.html"))
		url = []
		page.xpath('//a[@class="lientxt"]').each do |name|
			url << name.text.capitalize
		end
		push_sheet(url, 1)
		get_mail(url)
		
		
	end
#fonction qui vas dans les liens et vas chercher les adresses mails
	def get_mail(url)
		mail = []
		url.each do |ville|
				url_ville = ville.downcase.gsub(' ', '-')
				page = Nokogiri:: HTML(open("http://annuaire-des-mairies.com/50/#{url_ville}"))
				mail << page.css('p:contains("@")').text.slice(1..-1)
		end
		push_sheet(mail, 2)
		e_mail
	end
#fonction qui envoie les deux tableaux sur le spreadsheet
	def push_sheet(truc, c)
		session = GoogleDrive::Session.from_config("config.json")
		tab = session.spreadsheet_by_key("1GVTM1MB0SAVEpSem_7bH94irGJq8nrWg3gInFRfezsI").worksheets[0]
		tab[1,1] = "villes"						
		i = 1
		tab[1, c] = "adresses"
		truc.each do |x|
			i += 1
			tab[i, c] = x
		end
		tab.save
	end
# et le derniere fonction qui envoie les mails
	def e_mail 
		session = GoogleDrive::Session.from_config("config.json")
		tab = session.spreadsheet_by_key("1GVTM1MB0SAVEpSem_7bH94irGJq8nrWg3gInFRfezsI").worksheets[0]
		puts "qu'elle est ton adresse gmail?"
		id = gets.chomp
		puts "et ton mot de passe?"
		mdp = gets.chomp
		gmail = Gmail.connect(id, mdp)
#boucle qui s'arrête si la premiére colonne est vide, et qui descend a la ligne du dessous si il n'y a aps d'adresse
		i = 2
		while tab[i, 1].empty? == false
			if tab[i, 2].empty? == true
				i += 1
			else
				gmail.deliver do
					to tab[i, 2]
					subject "The Hacking Project à #{tab[i, 1]}"
					text_part do 
						body "Bonjour,
							Je m'appelle Paul, je suis élève à une formation de code gratuite, ouverte à tous, sans restriction 
							géographique, ni restriction de niveau. La formation s'appelle The Hacking Project (http://thehackingproject.org/). 
							Nous apprenons l'informatique via la méthode du peer-learning : nous faisons des projets concrets qui nous sont assignés 
							tous les jours, sur lesquel nous planchons en petites équipes autonomes. Le projet du jour est d'envoyer des emails à nos 
							élus locaux pour qu'ils nous aident à faire de The Hacking Project un nouveau format d'éducation gratuite.
							Nous vous contactons pour vous parler du projet, et vous dire que vous pouvez ouvrir une cellule à #{tab[i, 1]}, où vous pouvez 
							former gratuitement 6 personnes (ou plus), qu'elles soient débutantes, ou confirmées. Le modèle d'éducation de The Hacking Project 
							n'a pas de limite en terme de nombre de moussaillons (c'est comme cela que l'on appelle les élèves), donc nous serions ravis de travailler avec #{tab[i, 1]} !
							Charles, co-fondateur de The Hacking Project pourra répondre à toutes vos questions : 06.95.46.60.80"
							i += 1	
						end
					end
				end
			end
			gmail.logout
		end

# et c'est partis mon kiki!!!!
get_url