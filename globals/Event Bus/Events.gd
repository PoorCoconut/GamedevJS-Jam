extends Node
#The Events bus is a place where you can pass around signals in a clean manner
#Below is an example of a signal. This signal is connected via code in the PlayerHUD


signal player_hp_updated(current_hp, max_hp)
signal player_fuel_updated(current_fuel: float, max_fuel: float)
