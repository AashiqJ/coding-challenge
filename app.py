from flask import Flask, request

app = Flask(__name__)
nolist = []

# Function for add values to the list
def listAdd(num):
    nolist.append(num)

# Function to adding all the values in the list
def listTotal(noList):
    total = 0
# iterating over the list
    for element in noList:
   # checking whether its a number or not
        if isinstance(element, int) or element.isdigit():
      # adding the element to the total
            total += int(element)
    return str(total)

# POST method
@app.route('/',methods=['POST'])
def home():
    number = request.headers.get('Number')
    listAdd(number)
    return 'Added'

# GET method
@app.route('/',methods=['GET',])
def status():
    return listTotal(nolist)

# Main method
if __name__ == "__main__":
    app.run(host="0.0.0.0", port="5000")
