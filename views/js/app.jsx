class App extends React.Component {
    render(){
            return (<Words />)
    }
}


class Words extends React.Component{
    constructor(props){
        super(props);
        this.state = {
           word:'',
           wordresult: [],
        }
    }

    onSubmit = event => {
        event.preventDefault();
        const inp = this.input.value;
        console.log(inp)
        fetch(`/api/words?value=${encodeURIComponent(inp)}`,{
            "method":"GET",
        })
        .then(response => {return response.json()})
        .then((data) => {
            console.log("hello")
            console.log(data);
            this.setState({
                word: inp,
                wordresult: data.wordresult,
            });
        })
        .catch(err => {
            console.log(err)
        });
    }

    render() {
        const wr = this.state.wordresult;
        const w = this.state.word;
        const a = Array.from(wr)
        console.log(Array.isArray(wr))
        return (
        <div className="container">
                <div className="col-xs-8 col-xs-offset-2 jumbotron text-center" >
                    <h2>Urban Dictionary</h2>

                    <form onSubmit={this.onSubmit}>

                        <label htmlFor="word">Word</label>
                        <input
                            type="text"
                            name="word"
                            defaultValue="hell"
                            ref={input => this.input = input}
                        />
                        <button 
                            type="submit" 
                            className="btn btn-primary"
                            >Get
                            
                        </button>
                    </form>
                            <h2># {w}</h2>
                            {a.map((entry,index) => (
                                <div key={index} class="container p-3 my-3 border">
                                    <span><b>Definition : </b>{entry.definition}</span><br/>
                                    <span><b>Example : </b>{entry.example}</span><br/>
                                    <span><b>Author :</b> {entry.author}</span><br/>
                                    <span><b>ThumbsUp :</b> {entry.thumbs_up}</span><br/><br/>
                                </div>
                            
                            ))}
                </div>
          </div>
        )
    }
}


ReactDOM.render(<App />, document.getElementById('app'));