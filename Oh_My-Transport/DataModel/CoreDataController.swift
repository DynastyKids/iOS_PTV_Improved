//
//  CoreDataController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 20/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
    let DEFAULT_TEAM_NAME = "Default Team"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    //Results
    var allHeroesFetchedResultsController: NSFetchedResultsController<SuperHero>?
    var teamHeroesFetchedResultsController: NSFetchedResultsController<SuperHero>?
    
    override init(){
        persistantContainer = NSPersistentContainer(name: "Week04-SuperHeroes")
        persistantContainer.loadPersistentStores(){ (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack:\(error)")
            }
        }
        
        // If there are no heroes in the database assume that the app is running
        // for the first time. Create the default team and initial superheroes.
        super.init()
        
        if fetchAllHeroes().count == 0{
            createDefaultEntries()
        }
    }
    
    func saveContext(){
        if persistantContainer.viewContext.hasChanges{
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addSuperHero(name: String, abilities: String) -> SuperHero {
        let hero = NSEntityDescription.insertNewObject(forEntityName: "SuperHero", into: persistantContainer.viewContext) as! SuperHero
        hero.name = name
        hero.abilities = abilities
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return hero
    }
    
    func addTeam(teamName: String) -> Team {
        let team = NSEntityDescription.insertNewObject(forEntityName: "Team", into: persistantContainer.viewContext) as! Team
        team.name = teamName
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return team
    }
    
    func addHeroToTeam(hero: SuperHero, team: Team) -> Bool {
        guard let heroes = team.heroes, heroes.contains(hero) == false, heroes.count < 6 else{
            return false
        }
        
        team.addToHeroes(hero)
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return true
    }
    
    func deleteSuperHero(hero: SuperHero) {
        persistantContainer.viewContext.delete(hero)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    func deleteTeam(team: Team) {
        persistantContainer.viewContext.delete(team)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    func removeHeroFromTeam(hero: SuperHero, team: Team) {
        team.removeFromHeroes(hero)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.team || listener.listenerType == ListenerType.all{
            listener.onTeamChange(change: .update, teamHeroes: fetchTeamHeroes())
        }
        
        if listener.listenerType == ListenerType.heroes || listener.listenerType == ListenerType.all{
            listener.onHeroListChange(change: .update, heroes: fetchAllHeroes())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllHeroes() -> [SuperHero]{
        if allHeroesFetchedResultsController == nil{
            let fetchRequest: NSFetchRequest<SuperHero> = SuperHero.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allHeroesFetchedResultsController = NSFetchedResultsController<SuperHero>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allHeroesFetchedResultsController?.delegate = self
            
            do{
                try allHeroesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var heroes=[SuperHero]()
        if allHeroesFetchedResultsController?.fetchedObjects != nil {
            heroes = (allHeroesFetchedResultsController?.fetchedObjects)!
        }
        
        return heroes
    }
    
    func fetchTeamHeroes() -> [SuperHero] {
        if teamHeroesFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<SuperHero> = SuperHero.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            let predicate = NSPredicate(format: "ANY teams.name == %@", DEFAULT_TEAM_NAME)
            fetchRequest.predicate = predicate
            teamHeroesFetchedResultsController = NSFetchedResultsController<SuperHero>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName:nil)
            teamHeroesFetchedResultsController?.delegate = self
            
            do {
                try teamHeroesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        var heroes = [SuperHero]()
        if teamHeroesFetchedResultsController?.fetchedObjects != nil {
            heroes = (teamHeroesFetchedResultsController?.fetchedObjects)!
        }
        
        return heroes
    }
    
    private func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        if controller == allHeroesFetchedResultsController{
            listeners.invoke{ (listener) in
                if listener.listenerType == ListenerType.heroes || listener.listenerType == ListenerType.all {
                    listener.onHeroListChange(change: .update, heroes: fetchAllHeroes())
                }
            }
        }else if controller == teamHeroesFetchedResultsController{
            listeners.invoke{ (listener) in
                if listener.listenerType == ListenerType.team || listener.listenerType == ListenerType.all{
                    listener.onTeamChange(change: .update, teamHeroes: fetchTeamHeroes())
                }
            }
        }
    }
    
    lazy var defaultTeam: Team = {
        var teams = [Team]()
        
        let request: NSFetchRequest<Team> = Team.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", self.DEFAULT_TEAM_NAME)
        request.predicate = predicate
        
        do{
            try teams = self.persistantContainer.viewContext.fetch(Team.fetchRequest()) as! [Team]
        } catch{
            print("Fetch Request failed: \(error)")
        }
        
        if teams.count == 0 {
            return self.addTeam(teamName: DEFAULT_TEAM_NAME)
        } else {
            return teams.first!
        }
    }()
    
    func createDefaultEntries(){
        let _ = addSuperHero(name: "Bruce Wayne", abilities: "Is Rich")
        let _ = addSuperHero(name: "Superman", abilities: "Super Powered Alien")
        let _ = addSuperHero(name: "Wonder Woman", abilities: "Goddess")
        let _ = addSuperHero(name: "The Flash", abilities: "Faster than speed of light")
        let _ = addSuperHero(name: "Green Lantern", abilities: "Has a magic ring")
        let _ = addSuperHero(name: "Cyborg", abilities: "Is a cyborg")
        let _ = addSuperHero(name: "Aquaman", abilities: "Can breathe underwater")
    }
}
