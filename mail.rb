require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'google_drive'
require 'gmail'



def get_url
	#connection a gmail
	puts "qu'elle est ton adresse gmail?"
	gmail = gets.chomp
	puts "et ton mot de passe?"
	mdp = gets.chomp
	gmail = Gmail.connect('Gmail', 'mdp')
	#lien vers le spreadsheet
	session = GoogleDrive::Session.from_config("config.json")
	ws = session.spreadsheet_by_key("1qfrot2JxoKWvCrW7DUHkeDB430ntKsbQnMsm55Y6zpU").worksheets[0]
		#scrap du lien des mairies
		page = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/manche.html"))
		url = []
			page.xpath('//a[@class="lientxt"]').each do |name|
				url << name.text.capitalize
			end
			#envoie dans le spreasheet
			i = 1
			ws[1, 1] = "villes"
			url.each do |x|
				i+=1
				ws[i, 1] = x	
			end
			#sauvegarde
			ws.save
			#scrap des adresse mails
			mail = []
			url.each do |ville|
				url_ville = ville.downcase.gsub(' ','-')
				page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/50/#{url_ville}"))
				mail << page.css('p:contains("@")').text.slice(1..-1)
			end
			#envoie dans le tableau
			j = 2
			ws[1, 2] = "adresses"
			mail.each do |y|
				ws[j, 2] = y
				j += 1
			end
			#sauvegarde
			ws.save

			session = GoogleDrive::Session.from_config("config.json")
			ws = session.spreadsheet_by_key("1qfrot2JxoKWvCrW7DUHkeDB430ntKsbQnMsm55Y6zpU").worksheets[0]
			gmail = Gmail.connect('gmail', 'mdp') 
			#boucle si la colonne adresse est vide i+1
			i = 1
			while ws[i, 1].empty? == false
				if ws[i, 2].empty? == true 
				i += 1
					else
						#envoie du mail
					gmail.deliver do
						to ws[i, 2]
						subject "The Hacking Project à #{ws[i, 1]}"
							text_part do 
							body "Bonjour,
							Je m'appelle Paul, je suis élève à une formation de code gratuite, ouverte à tous, sans restriction 
							géographique, ni restriction de niveau. La formation s'appelle The Hacking Project (http://thehackingproject.org/). 
							Nous apprenons l'informatique via la méthode du peer-learning : nous faisons des projets concrets qui nous sont assignés 
							tous les jours, sur lesquel nous planchons en petites équipes autonomes. Le projet du jour est d'envoyer des emails à nos 
							élus locaux pour qu'ils nous aident à faire de The Hacking Project un nouveau format d'éducation gratuite.
							Nous vous contactons pour vous parler du projet, et vous dire que vous pouvez ouvrir une cellule à #{ws[i, 1]}, où vous pouvez 
							former gratuitement 6 personnes (ou plus), qu'elles soient débutantes, ou confirmées. Le modèle d'éducation de The Hacking Project 
							n'a pas de limite en terme de nombre de moussaillons (c'est comme cela que l'on appelle les élèves), donc nous serions ravis de travailler avec #{ws[i, 1]} !
							Charles, co-fondateur de The Hacking Project pourra répondre à toutes vos questions : 06.95.46.60.80"
							i += 1	
					end
				end
			end
		end
		#déconnection 
	gmail.logout
end
get_url







