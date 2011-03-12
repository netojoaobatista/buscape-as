package com.buscape.developer {
	import com.buscape.developer.result.CountryCode;
	import com.buscape.developer.result.ResultFormat;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	/**
	 * A classe BuscapeAPI foi criada para ajudar no desenvolvimento
	 * de aplicações usando os webservices disponibilizados pela API
	 * do BuscaPé.
	 * 
	 * Os métodos desta classe tem os mesmos nomes dos serviços disponibilizados
	 * pelo BuscaPé.
	 * 
	 * @author João Batista Neto
	 * @version 0.0.1
	 * @license GNU Lesser General Public License Version 2.1, February 1999
	 */
	public class BuscapeAPI extends EventDispatcher {
		private var applicationId :String;
		private var countryCode :CountryCode = CountryCode.BR;
		private var environment :String = 'bws';
		private var format :ResultFormat = ResultFormat.XML;
		private var sourceId :String;
		private var response :String;
		private var loader :URLLoader;
		
		/**
		 * A cada instância criada deverá ser passado como parâmetro obrigatório o id da
		 * aplicação. O Source ID não é obrigatório
		 * 
		 * @param applicationId O id da aplicação
		 * @param sourceId
		 */
		public function BuscapeAPI( applicationId :String , sourceId :String = null ) {
			this.setApplicationId( applicationId );
			this.setSourceId( sourceId );
		}
		
		/**
		 * Serviço utilizado somente na integração do Aplicativo com o Lomadee. Dentro
		 * do fluxo de integração, o aplicativo utiliza esse serviço para criar sourceId
		 * (código) para o Publisher que deseja utiliza-lo. Os parâmetros necessários
		 * neste serviço são informados pelo próprio Lomadee ao aplicativo. No ambiente
		 * de homologação sandbox, os valores dos parâmetros podem ser fictícios pois
		 * neste ambiente este serviço retornará sempre o mesmo sourceId para os testes
		 * do Developer.
		 * 
		 * @param sourceName Nome do código.
		 * @param publisherId ID do publisher
		 * @param siteId ID do site selecionado pelo publisher.
		 * @param campaignList Lista de IDs das campanhas separados por vírgula.
		 * @param token Token utilizado para validação da requisição.
		 */
		public function createSource( sourceName :String , publisherId :String , siteId :String , campaignList :Array , token :String ) :void {
			var args :URLVariables = new URLVariables();
			
			args.sourceName = sourceName;
			args.publisherId = publisherId;
			args.siteId = siteId;
			args.campaignList = campaignList.join( ',' );
			args.token = token;
			
			call( 'createSource' , args , true );
		}
		
		/**
		 * Busca de categorias, permite que você exiba informações relativas às
		 * categorias. É possível obter categorias, produtos ou ofertas informando
		 * apenas um ID de categoria.
		 * 
		 * Se não for informado nenhum dos parâmetros, será retornado por padrão uma
		 * lista de categorias raiz, de id 0.
		 * 
		 * @param categoryId O id da categoria
		 * @param keyword Palavra-chave buscada entre as categorias
		 */
		public function findCategoryList( categoryId :uint = 0 , keyword :String = null ) :void {
			var args :URLVariables = new URLVariables();
			
			args.categoryId = categoryId;
			
			if ( keyword != null ) {
				args.keyword = keyword;
			}
			
			call( 'findCategoryList' , args );
		}
		
		/**
		 * Busca uma lista de ofertas. É possível obter a lista de ofertas
		 * informando o ID do produto.
		 * 
		 * Pelo menos um dos parâmetros de pesquisa devem ser informados para
		 * o retorno da função. Os parâmetros categoryId e keyword podem ser usados
		 * em conjunto.
		 * 
		 * @param categoryId Id da categoria
		 * @param keyword Palavra-chave buscada entre as categorias
		 * @param productId Id do produto
		 * @param boolean lomadee Indica se deverá ser utilizada a API do Lomadee
		 */
		public function findOfferList( categoryId :uint = NaN , keyword :String = null , productId :uint = NaN , lomadee :Boolean = false ) :void {
			var args :URLVariables = new URLVariables();
			
			if ( !isNaN( categoryId ) ) {
				args.categoryId = categoryId;
			}
			
			if ( keyword != null ) {
				args.keyword = keyword;
			}
			
			if ( !isNaN( productId ) ) {
				args.productId = productId;
			}
			
			call( 'findOfferList' , args , lomadee );
		}
		
		/**
		 * Busca uma lista de produtos únicos utilizando o id da categoria final ou um
		 * conjunto de palavras-chaves ou ambos.
		 * 
		 * Pelo menos um dos parâmetros, categoryID ou keyword são requeridos para
		 * funcionamento desta função. Os dois também podem ser usados em conjunto. Ou
		 * seja, podemos buscar uma palavra-chave em apenas uma determinada categoria.
		 * 
		 * @param categoryId Id da categoria
		 * @param keyword Palavra-chave buscada entre as categorias
		 * @param lomadee Indica se deverá ser utilizada a API do Lomadee
		 */
		public function findProductList( categoryId :uint = 0 , keyword :String = null , lomadee :Boolean = false ) :void {
			var args :URLVariables = new URLVariables();
			
			if ( !isNaN( categoryId ) ) {
				args.categoryId = categoryId;
			}
			
			if ( keyword != null ) {
				args.keyword = keyword;
			}
			
			call( 'findProductList' , args , lomadee );
		}
		
		
		/**
		 * Recupera a resposta da requisição
		 */
		public function get result() :String {
			return response;
		}
		
		/**
		 * Retorna o Id da aplicação
		 */
		public function getApplicationId() :String {
			return this.applicationId;
		}
		
		private function call( serviceName :String , args :URLVariables = null , lomadee :Boolean = false ) :void {
			var request :URLRequest;
			
			if ( args == null ) {
				args = new URLVariables();
			}
			
			if ( lomadee ) {
				serviceName += '/lomadee';
			}
			
			if ( this.sourceId != null ) {
				args.sourceId = this.sourceId;
			}
			
			args.format = this.format;
			
			request = new URLRequest( [ 'http:/' , [ this.environment , 'buscape.com/service' ].join( '.' ) , serviceName , this.applicationId , this.countryCode , null ].join( '/' ) );
			request.data = args;
			
			loader = new URLLoader();
			loader.load( request );
			loader.addEventListener( IOErrorEvent.IO_ERROR , handleIOErrorEvent );
			loader.addEventListener( Event.COMPLETE , handleCompleteEvent );
		}
		
		private function handleIOErrorEvent( event :IOErrorEvent ) :void {
			loader.removeEventListener( IOErrorEvent.IO_ERROR , handleIOErrorEvent );
			dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );
		}
		
		private function handleCompleteEvent( event :Event ) :void {
			response = URLLoader( event.target ).data;
			
			loader.removeEventListener( Event.COMPLETE , handleCompleteEvent );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		/**
		 * Retorna o código do país
		 */
		public function getCountryCode() :CountryCode {
			return this.countryCode;
		}
		
		/**
		 * Retorna o ambiente de integração
		 */
		public function getEnvironment() :String {
			return this.environment;
		}
		
		/**
		 * Retorna o formato de retorno
		 */
		public function getFormat() :ResultFormat {
			return this.format;
		}
		
		/**
		 * Retorna o Source ID
		 */
		public function getSourceId() :String {
			return this.sourceId;
		}
		
		/**
		 * Define que as requisições serão feitas no sandbox
		 */
		public function sandbox() :BuscapeAPI {
			this.environment = 'sandbox';
			
			return this;
		}
		
		/**
		 * Define o Id da aplicação
		 *
		 * @param applicationId O id da aplicação
		 * @throws Caso o ID da aplicação seja inválido
		 */
		public function setApplicationId( applicationId :String ) :void {
			if ( applicationId.split( ' ' ).join( '' ).length == 0 ) {
				throw new Error( 'Id da aplicação inválido' );
			} else {
				this.applicationId = applicationId;
			}
		}
		
		/**
		 * Define o código do país
		 * 
		 * @param countryCode O código do país
		 */
		public function setCountryCode( countryCode :CountryCode ) :void {
			this.countryCode = countryCode;
		}
		
		/**
		 * Define o formato de retorno
		 * 
		 * @param format O formato da resposta
		 */
		public function setFormat( format :ResultFormat ) :void {
			this.format = format;
		}

		/**
		 * Define o Source Id
		 * 
		 * @param sourceId
		 */
		public function setSourceId( sourceId :String ) :void {
			this.sourceId = sourceId;
		}
		
		/**
		 * Recupera os produtos mais populares do BuscaPé
		 */
		public function topProducts() :void {
			call( 'topProducts' );
		}
		
		/**
		 * Recupera os detalhes técnicos de um determinado produto.
		 * 
		 * @param productId ID do produto
		 */
		public function viewProductDetails( productId :uint ) :void {
			var args :URLVariables = new URLVariables();
			
			args.productId = productId;
			
			call( 'viewProductDetails' , args );
		}
		
		/**
		 * Recupera os detalhes da loja/empresa como: endereços, telefones de
		 * contato etc...
		 * 
		 * @param sellerId Id da loja/empresa
		 */
		public function viewSellerDetails( sellerId :uint ) :void {
			var args :URLVariables = new URLVariables();
			
			args.sellerId = sellerId;
			
			call( 'viewSellerDetails' , args );
		}
		
		/**
		 * Recupera as avaliações dos usuários sobre um determinado produto
		 * 
		 * @param productId Id do produto
		 */
		public function viewUserRattings( productId :uint ) :void {
			var args :URLVariables = new URLVariables();
			
			args.productId = productId;
			
			call( 'viewUserRattings' , args );
		}
	}
}